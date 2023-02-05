#Load Balancer for Jenkins Server
resource "aws_lb" "PAADEU2-Jenkins-LB" {
  name               = "PAADEU2-Jenkins-LB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Jenkins_lb_sg.id]
  subnets            = [aws_subnet.SnPub1.id, aws_subnet.SnPub2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "PAADEU2-LB"
  }
}

#Target group for Jenkins 
resource "aws_lb_target_group" "PAADEU2-Jenkins-lb-tg" {
  name     = "PAADEU2-Jenkins-lb-tg"
  port     = var.jenkins_port
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

#Load Balancer Listener for Jenkins  Server 
resource "aws_lb_listener" "PAAEU2_Jenkins_lb_listener" {
  load_balancer_arn = aws_lb.PAADEU2-Jenkins-LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PAADEU2-Jenkins-lb-tg.arn
  }
}

#Target for Jenkins  server
resource "aws_lb_target_group_attachment" "PAADEU2-jenkins-lb-tgroup-attach" {
  target_group_arn = aws_lb_target_group.PAADEU2-Jenkins-lb-tg.arn
  target_id        = aws_instance.PPADEU2_jenkins_server.id
  port             = var.jenkins_port
}

#Security group for Jenkins  Load Balancer (same as Jenkins  LB SG)
resource "aws_security_group" "Jenkins_lb_sg" {
  name        = "Jenkins_lb_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.PAADEU2_vpc.id

  ingress {
    description = "Jenkins "
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
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
    Name = "Jenkins_lb_sg"
  }
}