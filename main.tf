terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}

provider "aws" {
  region = var.region
}

# Use default VPC and its subnets
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "default_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# Security group for EC2 and ALB
resource "aws_security_group" "web_security_group" {
  name        = "web-security-group"
  description = "Allow HTTP from anywhere"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "web-security-group"
  }
}

# Launch 2 EC2 instances with Apache
resource "aws_instance" "web_server" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  count                  = 2
  subnet_id              = data.aws_subnets.default_public_subnets.ids[count.index]
  vpc_security_group_ids = [aws_security_group.web_security_group.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "web-server-${count.index}"
  }
}

# Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default_public_subnets.ids
  security_groups    = [aws_security_group.web_security_group.id]

  tags = {
    Name = "web-alb"
  }
}

# Target group for ALB
resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# HTTP listener on ALB
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

# Attach EC2 instances to ALB target group
resource "aws_lb_target_group_attachment" "web_attachments" {
  count            = length(aws_instance.web_server)
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.web_server[count.index].id
  port             = 80
}
