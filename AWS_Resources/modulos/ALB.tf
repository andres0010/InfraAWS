
resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group.id]
  subnets            = [aws_subnet.subnet_publica_1.id, aws_subnet.subnet_publica_2.id]
}

resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpcGeneral.id
  target_type = "ip" # Ajuste importante para Fargate con awsvpc

  health_check {
    path     = "/health"
    port     = var.container_port
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}
