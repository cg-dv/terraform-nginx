resource "aws_lb" "example-alb" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http.id]
  subnets            = [aws_subnet.example_subnet_1.id, aws_subnet.example_subnet_2.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "example-tg" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.example-alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example-tg.arn
  }
}

output "alb_ip" {
  value       = aws_lb.example-alb.dns_name
  description = "Public DNS name of application load balancer."

  depends_on = [
    aws_lb.example-alb
  ]
}
