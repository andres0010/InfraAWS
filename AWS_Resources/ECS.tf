provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "my_cluster" {
  name = var.ecs_cluster_name
}