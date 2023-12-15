provider "aws" {
  region = var.region
}

resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_security_group.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
  target_type = "ip"  # Ajuste importante para Fargate con awsvpc

  health_check {
    path     = "/health"  # Ajusta según las necesidades de tu aplicación
    port     = var.container_port
    protocol = "HTTP"
  }
}

