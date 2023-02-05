#Load Balancer for Docker Server
resource "aws_lb" "PAADEU2-Docker-LB" {
  name               = "PAADEU2-Docker-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.docker_lb_sg.id]
  subnets            = [aws_subnet.SnPub1.id, aws_subnet.SnPub2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "PAADEU2-LB"
  }
}

#Target group for Docker
resource "aws_lb_target_group" "PAADEU2-Docker-lb-tg" {
  name     = "PAADEU2-Docker-lb-tg"
  port     = var.docker_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.PAADEU2_vpc.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    # target              = 8080
    interval = 30
  }
}

#Load Balancer Listener for Docker Server 
resource "aws_lb_listener" "PAAEU2_Docker_lb_listener" {
  load_balancer_arn = aws_lb.PAADEU2-Docker-LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PAADEU2-Docker-lb-tg.arn
  }
}

#Target for Docker server
resource "aws_lb_target_group_attachment" "PAADEU2-lb-tgroup-attach" {
  target_group_arn = aws_lb_target_group.PAADEU2-Docker-lb-tg.arn
  target_id        = aws_instance.PAADEU2_docker_server.id
  port             = var.docker_port
}

#Security group for Docker Load Balancer (same as Docker LB SG)
resource "aws_security_group" "docker_lb_sg" {
  name        = "docker_lb_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.PAADEU2_vpc.id

  ingress {
    description = "docker"
    from_port   = var.docker_port
    to_port     = var.docker_port
    cidr_blocks = [var.all_cidr]
    protocol    = "tcp"
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [var.all_cidr]
    protocol    = "tcp"
  }

  egress {
    from_port   = var.egress
    to_port     = var.egress
    protocol    = "-1"
    cidr_blocks = [var.all_cidr]
  }
  tags = {
    Name = "docker_lb_sg"
  }
}