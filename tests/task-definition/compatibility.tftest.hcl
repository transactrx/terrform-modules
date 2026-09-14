mock_provider "aws" {
  mock_resource "aws_iam_role" {
    defaults = { arn = "arn:aws:iam::123456789012:role/mocked" }
  }
}
run "legacy" {
  providers = { aws = aws }
  command   = apply
  state_key = "upgrade"
  module { source = "./before" }
}
run "upgrade" {
  providers = { aws = aws }
  command   = plan
  state_key = "upgrade"
  module { source = "./after" }
  assert {
    condition     = output.task == run.legacy.task
    error_message = "All existing module outputs must survive an unchanged consumer upgrade."
  }
}
run "external" {
  providers = { aws = aws }
  command   = plan
  module { source = "../../modules/task-definition" }
  variables {
    CPU                     = 256
    Memory                  = 512
    taskDefFamily           = "external"
    mainImageURL            = "example.invalid/app:fixed"
    ContainerList           = [{ name = "main", image = "$$MAIN_IMAGE$$", essential = true }]
    existing_task_role_arn  = "arn:aws:iam::123456789012:role/service/shared"
    ecs_execution_role_name = "regional-execution"
  }
  assert {
    condition     = length(aws_iam_role.ecs_task_role) == 0 && length(aws_iam_role_policy.ecs_exec) == 0
    error_message = "An external role and its policies must never be managed."
  }
  assert {
    condition     = output.task_role_arn == "arn:aws:iam::123456789012:role/service/shared" && output.task_role_name == "shared" && aws_ecs_task_definition.test.task_role_arn == output.task_role_arn
    error_message = "External ARN, including IAM paths, must preserve output semantics."
  }
  assert {
    condition     = aws_iam_role.ecs_task_execution_role.name == "regional-execution" && aws_iam_role_policy.secretsAccess.role == "regional-execution"
    error_message = "Execution-role behavior must remain unchanged."
  }
}
