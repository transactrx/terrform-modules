variable "name" {

}
resource "aws_ecs_cluster" "cluster" {
  name = var.name
}
resource "aws_ecs_cluster_capacity_providers" "cluster-capacity" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 3
    base              = 0
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}
output "name" {
  value = aws_ecs_cluster.cluster.name
}
