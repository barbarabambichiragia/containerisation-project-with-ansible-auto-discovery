resource "aws_lb" "PAADEU2-LB" {
  name               = "PAADEU2-LB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sonarqube_lb_sg.id]
  subnets            = [aws_subnet.SnPub1.id, aws_subnet.SnPub2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "PAADEU2-LB"
  }
}

resource "aws_lb_target_group" "PAADEU2-lb-tg" {
  name     = "PAADEU2-lb-tg"
  port     = var.sonarqube_port
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

resource "aws_lb_listener" "PAAEU2_lb_listener" {
  load_balancer_arn = aws_lb.PAADEU2-LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PAADEU2-lb-tg.arn
  }
}

#Target SonarQube 
resource "aws_lb_target_group_attachment" "PAADEU2-sonatqube-lb-tgroup-attach" {
  target_group_arn = aws_lb_target_group.PAADEU2-lb-tg.arn
  target_id        = aws_instance.PPADEU2_sonarqube_server.id
  port             = 9000
}
