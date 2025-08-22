#############################################
# PROVISION path (DDB + Lambda + SSM pointer)
#############################################

resource "aws_dynamodb_table" "seq" {
  count        = var.mode == "provision" ? 1 : 0
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = "name"

  attribute {
    name = "name"
    type = "S"
  }

  point_in_time_recovery { enabled = var.point_in_time_recovery }

  tags = var.tags
}

# Inline Lambda source
locals {
  lambda_source = <<-PY
import json, os, boto3
dynamodb = boto3.client("dynamodb")
TABLE = os.environ["TABLE_NAME"]

def _inc(name, step):
    resp = dynamodb.update_item(
        TableName=TABLE,
        Key={"name": {"S": name}},
        UpdateExpression="SET #v = if_not_exists(#v, :zero) + :inc",
        ExpressionAttributeNames={"#v": "value"},
        ExpressionAttributeValues={":zero": {"N": "0"}, ":inc": {"N": str(step)}},
        ReturnValues="UPDATED_NEW",
    )
    return int(resp["Attributes"]["value"]["N"])

def lambda_handler(event, context):
    name = "default"
    step = 1
    qsp = (event or {}).get("queryStringParameters") or {}
    if "name" in qsp: name = qsp["name"]
    if "step" in qsp:
        try: step = int(qsp["step"])
        except: pass
    if "name" in (event or {}): name = event["name"]
    if "step" in (event or {}):
        try: step = int(event["step"])
        except: pass
    val = _inc(name, step)
    body = {"name": name, "next": val}
    if "requestContext" in (event or {}) and "http" in event["requestContext"]:
        return {"statusCode": 200, "headers": {"content-type": "application/json"}, "body": json.dumps(body)}
    else:
        return body
PY
}

data "archive_file" "lambda_zip" {
  count       = var.mode == "provision" ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source {
    content  = local.lambda_source
    filename = "lambda_function.py"
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  count = var.mode == "provision" ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["lambda.amazonaws.com"] }
  }
}

resource "aws_iam_role" "lambda_role" {
  count              = var.mode == "provision" ? 1 : 0
  name               = "${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "lambda_inline" {
  count = var.mode == "provision" ? 1 : 0
  statement {
    sid     = "DynamoAccess"
    actions = ["dynamodb:UpdateItem","dynamodb:PutItem","dynamodb:GetItem","dynamodb:DescribeTable"]
    resources = [aws_dynamodb_table.seq[0].arn]
  }

  statement {
    sid     = "Logs"
    actions = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  count  = var.mode == "provision" ? 1 : 0
  name   = "${var.lambda_name}-policy"
  role   = aws_iam_role.lambda_role[0].id
  policy = data.aws_iam_policy_document.lambda_inline[0].json
}

resource "aws_lambda_function" "claim" {
  count         = var.mode == "provision" ? 1 : 0
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_role[0].arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  filename      = data.archive_file.lambda_zip[0].output_path
  timeout       = 5
  environment { variables = { TABLE_NAME = aws_dynamodb_table.seq[0].name } }
  tags = var.tags
}

resource "aws_lambda_function_url" "this" {
  count              = var.mode == "provision" && var.create_function_url ? 1 : 0
  function_name      = aws_lambda_function.claim[0].function_name
  authorization_type = var.function_url_auth_type
  cors {
    allow_methods = ["GET","POST","OPTIONS"]
    allow_origins = ["*"]
  }
}

# Publish the Lambda name to SSM so services can look it up easily
resource "aws_ssm_parameter" "lambda_pointer" {
  count = var.mode == "provision" ? 1 : 0
  name  = var.lambda_pointer_ssm_name
  type  = "String"
  value = aws_lambda_function.claim[0].function_name
  tags  = merge(var.tags, { purpose = "sequence-lambda-pointer" })
}

#############################################
# CLAIM path (service: get 10,20,30, ...)
#############################################

# Read the Lambda name from SSM
data "aws_ssm_parameter" "lambda_pointer_read" {
  count = var.mode == "claim" ? 1 : 0
  name  = var.lambda_pointer_ssm_name
}

# Invoke the Lambda to increment by 'step' and get the new number
data "aws_lambda_invocation" "claim_next" {
  count         = var.mode == "claim" ? 1 : 0
  function_name = data.aws_ssm_parameter.lambda_pointer_read[0].value
  input         = jsonencode({ name = var.sequence_name, step = var.step })
}

# Persist the claimed value so re-applies don't re-claim
locals {
  claimed_value = var.mode == "claim" ? tonumber(jsondecode(data.aws_lambda_invocation.claim_next[0].result).next) : null
  claim_param_name = var.mode == "claim" ? "${trim(var.claim_parameter_prefix, "/") == "" ? "" : "/"}${trim(var.claim_parameter_prefix, "/")}/${var.service_name}/alb_priority/${var.sequence_name}" : null
}

resource "aws_ssm_parameter" "claimed_priority" {
  count = var.mode == "claim" ? 1 : 0
  name  = local.claim_param_name
  type  = "String"
  value = tostring(local.claimed_value)

  lifecycle {
    ignore_changes = [value] # keep first claim forever (idempotent)
  }

  tags = merge(var.tags, {
    purpose  = "alb-priority"
    sequence = var.sequence_name
    service  = var.service_name
  })
}