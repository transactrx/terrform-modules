variable "ecsImage" {}
variable "additionalEnvVars" {

}

variable "ephemeralStorage" {
  type    = number
  default = 0
}

variable "useMongoConnection" {
  default = false
  type    = bool
}

variable "deploymentType" {
  default = "FARGATE"
}

variable "useNoAuthPgBouncer" {
  default = false
  type    = bool
}
variable "AdditionalSecrets" {
  type    = map
  default = {}
}
variable "servicePort" {
  default = "8080"
}
variable "privileged" {
  default = false
}

variable "appName" {}

variable "awsLogGroup" {}
variable "dataBase" {
  default = "prod"
}
variable "taskMemoryMb" {
  default = 2048
}
variable "taskCPU" {
  default = 256
}
variable "additionalCPU" {
  default = 0
}
variable "additionalMemory" {
  default = 0
}
variable "useStunnel" {

  type = bool
}
variable "useWaf" {
  type    = bool
  default = false
}
variable "useAppProxy" {
  type    = bool
  default = false
}

//for validation only
locals {
  both_UseWaf_and_useAppProxyCannotBeTrue = parseint(var.useWaf && var.useAppProxy?"not number" : "10", 10 )
}

variable "useMail" {

  type = bool
}
variable "usePgBouncer" {
  type = bool
}

variable "additionalContainers" {
  type    = list(string)
  default = []
}
variable "volumeFrom" {
  default = []
}
variable "volumes" {
  default = []
}
variable "mountPoints" {
  default = []
}
variable "useArm" {
  default = false
  type    = bool
}

variable "publicDomain" {}
variable "envPostFix" {
  default = ""
}
locals {
  envPostFix = length(var.envPostFix)>0?"-${var.envPostFix}" : ""
}

locals {

  stunnelMemory      = var.useStunnel? 56 : 0
  wafMemory          = var.useWaf? 180 : 0
  appProxyMemory     = var.useAppProxy? 180 : 0
  wafCPU             = var.useWaf ? 15 : 0
  appProxyCPU        = var.useAppProxy ? 15 : 0
  gmailMemory        = var.useMail? 35 : 0
  pgBouncerMemory    = var.usePgBouncer ? 100 : 0
  stunnelCPU         = var.useStunnel ? 8 : 0
  gmailCPU           = var.useMail ? 1 : 0
  pgBouncerCPU       = var.usePgBouncer ? 8 : 0
  identityServiceUrl = "https://${var.publicDomain}/isinterfaces"
}
locals {

  totalStaticMemory = local.stunnelMemory + local.gmailMemory + local.pgBouncerMemory + var.additionalMemory +local.wafMemory + local.appProxyMemory
  totalStaticCPU    = local.stunnelCPU + local.gmailCPU + local.pgBouncerCPU+var.additionalCPU + local.wafCPU +local.appProxyCPU

  mainContainerMemory = var.taskMemoryMb -( local.totalStaticMemory+50)
  mainContainerCPU    = var.taskCPU - local.totalStaticCPU

}

locals {
  additionalVars = join("\n", formatlist(",{\"name\":\"%s\",\"value\":\"%s\"}", keys(var.additionalEnvVars), values(var.additionalEnvVars)))
}

locals {


  pgBouncerSecrets = {
    DBUSER         = "${data.aws_cloudformation_export.appPostgresConn.value}:username::"
    DBPASSWORD     = "${data.aws_cloudformation_export.appPostgresConn.value}:password::"
    DB_OM_USER     = "${data.aws_cloudformation_export.appPostgresConn.value}:username::"
    DB_OM_PASSWORD = "${data.aws_cloudformation_export.appPostgresConn.value}:password::"
  }

  newAdditionSecrets = !var.useNoAuthPgBouncer?var.AdditionalSecrets : merge(var.AdditionalSecrets, local.pgBouncerSecrets)

  additionalSecrets0 = join("\n", formatlist("{\"name\":\"%s\",\"valueFrom\":\"%s\"},", keys(local.newAdditionSecrets), values(local.newAdditionSecrets)))
  additionalSecrets  = substr("${local.additionalSecrets0}", 0, length("${local.additionalSecrets0}")-1)

  defaultSecretsEnvMAIL             = !var.useMail ? "" : "{ \"name\": \"MAIL_PASSWORD\",\"valueFrom\": \"${data.aws_cloudformation_export.applicationsMailPassword.value}\"},{ \"name\": \"MAIL_USER\",\"valueFrom\": \"${data.aws_cloudformation_export.applicationsMailUser.value}\"}"
  defaultSecretsEnvMONGO_REPOSITORY = !var.useMongoConnection ? "" : "{ \"name\": \"MONGO_REPOSITORY_DB\",\"valueFrom\": \"${data.aws_cloudformation_export.applicationMongoDb.value}\"},{ \"name\": \"MONGODB_FULL_URI_JAVA\",\"valueFrom\": \"${data.aws_cloudformation_export.applicationMongoDbJavaUrl.value}\"}"
  defaultSecretsEnvJoin             = join(",", compact([
    local.defaultSecretsEnvMAIL, local.defaultSecretsEnvMONGO_REPOSITORY
  ]))
  othersAdditionalSecrets           = length("${local.defaultSecretsEnvJoin}")>0 ? ( length("${local.additionalSecrets0}")>0 ? ",${local.defaultSecretsEnvJoin}" : "${local.defaultSecretsEnvJoin}" ) : ""


}


//data "aws_cloudformation_export" "applicationsPostgresPassword" {
//  name = "WebAppsCommon-AppPGPassword"
//}
//data "aws_cloudformation_export" "applicationsPostgresUserName" {
//  name = "WebAppsCommon-AppPGUser"
//}

variable "preserveLog" {
  type    = bool
  default = false
}
resource "aws_cloudwatch_log_group" "logGroup" {
  name              = var.awsLogGroup
  retention_in_days = 30
}

#resource "aws_cloudwatch_log_subscription_filter" "toSumoAndS3" {
#  count = var.preserveLog ? 1 : 0
#  destination_arn = var.envObject.logsFireHoseArn
#  log_group_name = aws_cloudwatch_log_group.logGroup.name
#  filter_pattern = ""
#  name = "sendToSumoAndS3"
#  role_arn = var.envObject.logsFirehoseRoleArnForCWSubscription
#}




//chs ,metabase, repository,
locals {

  defaultEnvMAIN_DB              = !var.usePgBouncer ?"" : "{ \"name\": \"MAIN_DB\",\"value\": \"${var.dataBase}\"},"
  defaultEnvDB_OM_URL            = !var.usePgBouncer ?"" : "{ \"name\": \"DB_OM_URL\",\"value\": \"jdbc:postgresql://localhost:5432/${var.dataBase}\"},"
  defaultEnvDBURL                = !var.usePgBouncer ?"" : "{ \"name\": \"DBURL\",\"value\": \"jdbc:postgresql://localhost:5432/${var.dataBase}\"},"
  defaultEnvDBPASSWORD           = !var.usePgBouncer ?"" : (contains(keys(var.additionalEnvVars), "DBPASSWORD") || contains(keys(var.AdditionalSecrets), "DBPASSWORD")) ?"" : "{ \"name\": \"DBPASSWORD\",\"value\": \"fakeonePass1822\"},"
  defaultOBJECT_MODEL_DATASOURCE = !var.usePgBouncer ?"" : (contains(keys(var.additionalEnvVars), "OBJECT_MODEL_DATASOURCE") || contains(keys(var.AdditionalSecrets), "OBJECT_MODEL_DATASOURCE")) ?"" : "{ \"name\": \"OBJECT_MODEL_DATASOURCE\",\"value\": \"java:/comp/env/DsiDS\"},"
  defaultEnvDBUSER               = !var.usePgBouncer ?"" : (contains(keys(var.additionalEnvVars), "DBUSER") || contains(keys(var.AdditionalSecrets), "DBUSER")) ?"" : "{ \"name\": \"DBUSER\",\"value\": \"fakeuserheresas\"},"
  defaultEnvDBDRIVER             = !var.usePgBouncer ?"" : (contains(keys(var.additionalEnvVars), "DBDRIVER") || contains(keys(var.AdditionalSecrets), "DBDRIVER")) ?"" : "{ \"name\": \"DBDRIVER\",\"value\": \"org.postgresql.Driver\"},"
  defaultEnvDBSERVER             = !var.usePgBouncer ?"" : (contains(keys(var.additionalEnvVars), "DBSERVER") || contains(keys(var.AdditionalSecrets), "DBSERVER")) ?"" : "{ \"name\": \"DBSERVER\",\"value\": \"localhost\"},"
  defaultEnvDBHOST               = !var.usePgBouncer ?"" : (contains(keys(var.additionalEnvVars), "DBHOST") || contains(keys(var.AdditionalSecrets), "DBHOST")) ?"" : "{ \"name\": \"DBHOST\",\"value\": \"localhost\"},"
  defaultMailAddr                = !var.useMail?"" : (contains(keys(var.additionalEnvVars), "MAIL_ADDR") || contains(keys(var.AdditionalSecrets), "MAIL_ADDR")) ?"" : "{ \"name\": \"MAIL_ADDR\",\"value\": \"localhost\"},"
  defaultMailPort                = !var.useMail?"" : (contains(keys(var.additionalEnvVars), "MAIL_PORT") || contains(keys(var.AdditionalSecrets), "MAIL_PORT")) ?"" : "{ \"name\": \"MAIL_PORT\",\"value\": \"25\"},"
  defaultMailDebug               = !var.useMail?"" : (contains(keys(var.additionalEnvVars), "MAIL_DEBUG") || contains(keys(var.AdditionalSecrets), "MAIL_DEBUG")) ?"" : "{ \"name\": \"MAIL_DEBUG\",\"value\": \"FALSE\"},"
  defaultMailUseSSL              = !var.useMail?"" : (contains(keys(var.additionalEnvVars), "MAIL_USE_SSL") || contains(keys(var.AdditionalSecrets), "MAIL_USE_SSL")) ?"" : "{ \"name\": \"MAIL_USE_SSL\",\"value\": \"FALSE\"},"
  dependsOnPgbouncer             = var.usePgBouncer?"{\"containerName\": \"pgbouncer\", \"condition\": \"START\" }" : ""


}


locals {
  ports     = contains(var.nlbPorts[*].servicePort, var.nlbHealthCheckPort)?var.nlbPorts[*].servicePort : concat(var.nlbPorts[*].servicePort, [
    var.nlbHealthCheckPort
  ])
  protocols = contains(var.nlbPorts[*].servicePort, var.nlbHealthCheckPort)?var.nlbPorts[*].protocol : concat(var.nlbPorts[*].protocol, [
    "tcp"
  ])

}

locals {
  tempMainContainerPorts   = var.nlb?(join(",", formatlist("{\"hostPort\":%s,\"protocol\":\"%s\",\"containerPort\":%s}", local.ports, local.protocols, local.ports))) : ""
  tempMainContainerPorts2  = var.nlb?join("", ["[", local.tempMainContainerPorts, "]"]) : ""
  mainContainerPortMapping = var.nlb && !var.useStunnel ? jsonencode(jsondecode(local.tempMainContainerPorts2)) : "[]"
}


//main container definition
variable "memCachedHost" {
  default = ""
}
locals {
  mainContainerDef = <<DEFINITION
  {
      "cpu": ${local.mainContainerCPU},
      "environment": [
        {
              "name": "VERSION",
              "value": "1.3"
          },
          {
              "name": "APP_NAME",
              "value": "${var.appName}"
          },
          {
              "name": "APPID",
              "value": "${var.appName}"
          },
          {
              "name": "error403Url",
              "value": "/webusermanagement/resources/403-error.html"
          },
          {
              "name": "JAVA_OPTS",
              "value": "-Dcom.sun.jndi.rmi.object.trustURLCodebase=false -Dlog4j2.formatMsgNoLookups=true -Duser.timezone=America/Los_Angeles -Xmx${local.mainContainerMemory}m -Dnet.spy.log.LoggerImpl=net.spy.memcached.compat.log.SunLogger"
          },
          {
              "name": "MEMCACHED_SEED",
              "value": "${var.appName}"
          },
          {
              "name": "MEMCACHED_SERVERLIST",
              "value": "${var.memCachedHost}"
          },
          {
              "name": "TEMP_FOLDER",
              "value": "/home/temp"
          },
          {
              "name": "USE_MANAGED_ENTITY_MANAGERS",
              "value": "false"
          },
          {
              "name": "userCredentialIdentityServiceUrl",
              "value": "/rest/restapi/userdetails/"
          },
          ${local.defaultEnvDBURL}
          ${local.defaultEnvDB_OM_URL}
          ${local.defaultEnvMAIN_DB}
          ${var.useNoAuthPgBouncer?"":local.defaultEnvDBPASSWORD}
          ${var.useNoAuthPgBouncer?"":local.defaultEnvDBUSER}
          ${local.defaultEnvDBDRIVER}
          ${local.defaultEnvDBSERVER}
          ${local.defaultEnvDBHOST}
          ${local.defaultMailAddr}
          ${local.defaultMailPort}
          ${local.defaultMailDebug}
          ${local.defaultMailUseSSL}
          ${local.defaultOBJECT_MODEL_DATASOURCE}
          {
              "name": "IDENTITY_SERVICE_URL",
              "value": "${local.identityServiceUrl}"
          }
          ${local.additionalVars}


      ],
      "essential": true,
      "image": "${var.ecsImage}",
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.logGroup.name}",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "ecs"
          },
          "secretOptions": []
      },
      "memory": ${local.mainContainerMemory},
      "mountPoints": ${jsonencode(var.mountPoints)},
      ${var.privileged?"\"privileged\":true,":""}
      "name": "main",
      "portMappings": ${local.mainContainerPortMapping},
      "secrets": [
          ${local.additionalSecrets}
          ${local.othersAdditionalSecrets}
      ],
      "volumesFrom": ${jsonencode(var.volumeFrom)},
      "dependsOn": [${local.dependsOnPgbouncer}]
  }
DEFINITION
}


//mail container definition
variable "mailImageUri" {
  default = ""
}
locals {
  mailContainerDef = <<DEFINITION
 {
      "cpu": ${local.gmailCPU},
      "environment":[],
      "essential": true,
      "image": "${var.mailImageUri}",
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.logGroup.name}",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "ecs-mail"
          },
          "secretOptions": []
      },
      "memory": ${local.gmailMemory},
      "mountPoints": [],
      "name": "mail",
      "portMappings": [],
      "secrets": [
          {
              "valueFrom": "${data.aws_cloudformation_export.applicationsMailUser.value}",
              "name": "user"
          },
          {
              "valueFrom": "${data.aws_cloudformation_export.applicationsMailPassword.value}",
              "name": "pass"
          }
      ],
      "volumesFrom": []
  }
DEFINITION
}


//pgbouncer
variable "pgBouncerNoAuthImageUri" {
  default = ""
}
variable "pgBouncerImageUri" {
  default = ""
}
locals {
  PGBouncerContainerDef = <<DEFINITION
{
      "cpu": ${local.pgBouncerCPU},
      "environment": [
          {
              "name": "PG_PORT_5432_TCP_PORT",
              "value": "5432"
          },
          {
              "name":"PG_ROLE",
              "value":"rds_superuser"
          }
      ],
      "essential": true,
      "image": "${var.useNoAuthPgBouncer?var.pgBouncerNoAuthImageUri:var.pgBouncerImageUri}",
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.logGroup.name}",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "ecs-pgBouncer"
          },
          "secretOptions": []
      },
      "memory": ${local.pgBouncerMemory},
      "mountPoints": [],
      "name": "pgbouncer",
      "portMappings": [],
      "secrets": [
          {
              "valueFrom": "${data.aws_cloudformation_export.appPostgresConn.value}:password::",
              "name": "PG_ENV_POSTGRESQL_PASS"
          },
          {
              "valueFrom": "${data.aws_cloudformation_export.appPostgresConn.value}:username::",
              "name": "PG_ENV_POSTGRESQL_USER"
          },
          {
              "valueFrom": "${data.aws_cloudformation_export.appPostgresConn.value}:hostname::",
              "name": "PG_PORT_5432_TCP_ADDR"
          }
      ],
      "volumesFrom": []
 }
DEFINITION

}


//stunnel
variable "stunnelImageUri" {
  default = ""
}
locals {
  stunnelContainerDef = <<DEFINITION
  {
      "cpu": ${local.stunnelCPU},
      "environment": [
            {
                "name": "COMMONNAME",
                "value": "transactrxapp.com"
            },
            {
                "name": "DEST_PORT",
                "value": "localhost:${(var.useWaf || var.useAppProxy)?"80":var.servicePort}"
            }
      ],
      "essential" : true,
      "image": "${var.stunnelImageUri}",
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.logGroup.name}",
              "awslogs-region": "us-east-1",
              "awslogs-stream-prefix": "ecs-stunnel"
          },
          "secretOptions": []
      },
      "memory": ${local.stunnelMemory},
      "mountPoints": [],
      "name": "stunnel",
      "dependsOn": [
                {
                    "containerName": "main",
                    "condition": "START"
                }
      ],
      "portMappings": [
            {
                "hostPort": 443,
                "protocol": "tcp",
                "containerPort": 443
            }
      ],
      "secrets":[],
      "volumesFrom": []
 }
DEFINITION
}
//waf taskdef
variable "wafImageUri" {
  default = ""
}
locals {
  wafContainerdef = <<DEFINITION
        {

            "cpu": ${local.wafCPU},
            "environment": [
                {
                    "name": "PROXY_REDIRECT_IP",
                    "value": "localhost:${var.servicePort}"
                },
                {
                    "name": "CUSTOM_RULES_64",
                    "value": ""
                },
                {
                    "name": "LEARNING_MODE",
                    "value": "yes"
                }
            ],
            "memory": ${local.wafMemory},
            "image": "${var.wafImageUri}",
            "essential": true,
            "name": "waf"
        }
DEFINITION
}

//AppProxy Def
variable "appProxyImageUri" {
  default = ""
}
locals {
  appProxyContainerDef = <<DEFINITION
        {

            "cpu": ${local.appProxyCPU},
            "environment": [
                {
                    "name": "PROXY_REDIRECT_IP",
                    "value": "localhost:${var.servicePort}"
                },
                {
                    "name": "DBUSER",
                    "value": "FAKEONE"
                },
                {
                    "name": "DBPASSWORD",
                    "value": "FAKEONE"
                },
                {
                    "name": "DBHOST",
                    "value": "localhost"
                },
                {
                    "name": "MAIN_DB",
                    "value": "prod"
                },
                {
                    "name": "HEALTH_CHECK_URI",
                    "value":"${var.healthCheckPath}"
                }


            ],
            "memory": ${local.appProxyMemory},
            "image": "${var.appProxyImageUri}",
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "${aws_cloudwatch_log_group.logGroup.name}",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs-appproxy"
                },
                "secretOptions": []
            },

            "essential": true,
            "name": "appproxy",
            "dependsOn": [${local.dependsOnPgbouncer}]
        }
DEFINITION
}


//whole service
locals {

  fullTaskDef = <<DEFINITION
  [
    ${local.mainContainerDef}
    ${var.useMail ? "," : "" }
    ${var.useMail ? local.mailContainerDef:""}
    ${var.usePgBouncer?",":""}
    ${var.usePgBouncer?local.PGBouncerContainerDef:""}
    ${var.useStunnel ? "," : "" }
    ${var.useStunnel ? local.stunnelContainerDef : "" }
    ${var.useWaf ? "," : "" }
    ${var.useWaf ? local.wafContainerdef : "" }
    ${var.useAppProxy ? "," : "" }
    ${var.useAppProxy ? local.appProxyContainerDef:""}
    ${length(var.additionalContainers)>0 ? ",":""}
    ${length(var.additionalContainers)>0 ? trimsuffix(trimprefix(join(",",var.additionalContainers) ,"]"),"[") :""}
  ]
DEFINITION
}

data "aws_caller_identity" "current" {}


resource "aws_iam_role_policy" "secretsAccess" {
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "ecr"
        },
        {
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:*:*:secret:*",
            "Effect": "Allow",
            "Sid": "secretsmanager"
        },
        {
            "Action": [
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "ssmparameters"
        }
    ]
}
EOF
  role   = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = join("-", [
    "ecs",
    var.serviceName,
    "task-execution-role"
  ])

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF

}


resource "aws_iam_role" "ecs_task_role" {

  name = join("-", [
    "ecs",
    var.serviceName,
    "task-role"
  ])
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF

}

locals {
  policyForECSFargateExec = <<EOF
{
 "Statement": [{
    "Effect": "Allow",
    "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
    ],
    "Resource": "*"
  }]
}
EOF
}

resource "aws_iam_role_policy" "allowExecIntoContainer" {
  role   = aws_iam_role.ecs_task_role.name
  policy = local.policyForECSFargateExec
}

locals {
  ephemeralStorageStr = var.ephemeralStorage>0?",\"ephemeralStorage\": {\"sizeInGiB\": ${var.ephemeralStorage} }" : ""
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

locals {
  finalTaskDef = "{\"containerDefinitions\": ${local.fullTaskDef},\"volumes\":${jsonencode(var.volumes)},\"runtimePlatform\":${jsonencode(local.runtime_platform)} ${local.ephemeralStorageStr} }"
}

locals {
  taskDefFilename = ".ecs-taskDef-${var.serviceName}-${formatdate("DDMMMYYYYhh-mm-ss", timestamp())}"
}
locals {
  runtime_platform = {
    "operatingSystemFamily" = "LINUX",
    "cpuArchitecture"       = var.useArm? "ARM64" : "X86_64"
  }
}


resource "null_resource" "ecs_task_definition" {

  triggers = {
    taskDef = local.finalTaskDef
  }
  provisioner "local-exec" {
    environment = {
      taskDef = local.finalTaskDef
    }
    command = <<EOT
      echo "$taskDef">${local.taskDefFilename}
      aws ecs register-task-definition --family ecs-${var.serviceName} --cpu ${var.taskCPU} --memory ${var.taskMemoryMb} --requires-compatibilities ${var.deploymentType} --network-mode awsvpc  --task-role-arn ${aws_iam_role.ecs_task_role.arn} --execution-role-arn ${aws_iam_role.ecs_task_execution_role.arn} --cli-input-json file://${local.taskDefFilename}
    EOT
  }

}
resource "null_resource" "delete-temporary-file" {
  depends_on = [null_resource.ecs_task_definition]
  provisioner "local-exec" {
    command = "rm -f ${local.taskDefFilename}"
  }

}

data "aws_region" "currentRegion" {}

data "aws_ecs_task_definition" "taskDef" {
  depends_on      = [null_resource.ecs_task_definition]
  task_definition = "ecs-${var.serviceName}"
}

locals {
  taskDefinitionArn = "arn:aws:ecs:${data.aws_region.currentRegion.name}:${data.aws_caller_identity.current.account_id}:task-definition/${data.aws_ecs_task_definition.taskDef.family}:${data.aws_ecs_task_definition.taskDef.revision}"
}


//resource "aws_ecs_task_definition" "taskDef" {
//
//
//
//  cpu = var.taskCPU
//  memory = var.taskMemoryMb
//  container_definitions = data.local_file.sortedMainTaskDef.content
//  family = "ecs-${var.serviceName}"
//  requires_compatibilities = ["FARGATE","EC2"]
//  network_mode = "awsvpc"
//  tags = {
//    Source="terraform"
//    taskChecksum=local.taskDefChecksum
//  }
//  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
//  task_role_arn = aws_iam_role.ecs_task_role.arn
//
//  lifecycle {
//    ignore_changes = [container_definitions]
//  }
//
//}



























