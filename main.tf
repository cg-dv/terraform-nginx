provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "http" {
  name        = "http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.example.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.example.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.example.id
}

resource "aws_subnet" "example_subnet_1" {
  vpc_id               = aws_vpc.example.id
  cidr_block           = "10.0.1.0/24"
  availability_zone_id = "use1-az1"
}

resource "aws_subnet" "example_subnet_2" {
  vpc_id               = aws_vpc.example.id
  cidr_block           = "10.0.2.0/24"
  availability_zone_id = "use1-az2"
}

resource "aws_lb" "test" {
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

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.example-tg.arn
  target_id        = aws_lb_target_group.example-tg.id
  port             = 80
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.bar.name
  alb_target_group_arn   = aws_lb_target_group.example-tg.arn
}

resource "aws_launch_configuration" "example-lc" {
  name          = "terraform-lc"
  image_id      = "ami-0394780d7884654b5"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "bar" {
  name                      = "foobar3-terraform-test"
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 300
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = aws_launch_configuration.example-lc.name
  target_group_arns         = [aws_lb_target_group.example-tg.arn]
  vpc_zone_identifier       = [aws_subnet.example_subnet_1.id, aws_subnet.example_subnet_2.id]

  initial_lifecycle_hook {
    name                 = "foobar"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }
}
