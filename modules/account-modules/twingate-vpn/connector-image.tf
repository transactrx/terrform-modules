# ------------------------------------------------------------------------------------------------------------------
# Always run the current Twingate connector release - without anyone passing a version.
#
# The task definition used to reference the floating tag "twingate/connector:1". Terraform never saw a change,
# so the connector only updated when a task happened to be relaunched (RAS was found running 1.83.0 while 1.92.0
# was current). Instead we resolve the floating tag to its image digest at plan time and put THAT in the task
# definition: every deploy compares the running connector against Twingate's current release; when a new release
# exists the plan shows the image change and ECS rolls the connector, otherwise nothing restarts.
# ------------------------------------------------------------------------------------------------------------------
variable "connector_track" {
  description = "twingate/connector tag to follow (a major track). Resolved to its current digest on every plan."
  type        = string
  default     = "1"
}

data "http" "twingate_connector_tag" {
  url = "https://hub.docker.com/v2/repositories/twingate/connector/tags/${var.connector_track}"
  request_headers = {
    Accept = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200 && can(jsondecode(self.response_body).digest)
      error_message = "Could not resolve twingate/connector:${var.connector_track} on Docker Hub (HTTP ${self.status_code})."
    }
  }
}

locals {
  twingate_connector_image = "twingate/connector@${jsondecode(data.http.twingate_connector_tag.response_body).digest}"
}
