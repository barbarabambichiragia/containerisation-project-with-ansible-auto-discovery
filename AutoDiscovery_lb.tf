
#Create AMI from Instance 
resource "aws_ami_from_instance" "PPADEU2-docker-ami" {
  name               = "PPADEU2-docker-ami"
  source_instance_id = aws_instance.PAADEU2_docker_server.id
}

#Load Balancer for AutoDiscovery 
resource "aws_lb" "PAADEU2-AutoDisc-LB" {
  name               = "PAADEU2-AutoDisc-LB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.docker_lb_sg.id]
  subnets            = [aws_subnet.SnPub1.id, aws_subnet.SnPub2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "PAADEU2-LB"
  }
}

#Target group for ASG
resource "aws_lb_target_group" "PAADEU2-AutoDisc-lb-tg" {
  name     = "PAADEU2-AutoDisc-lb-tg"
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

#AMI Load Balancer Listener for ASG
resource "aws_lb_listener" "PAAEU2_AutoDisc_lb_listener" {
  load_balancer_arn = aws_lb.PAADEU2-AutoDisc-LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PAADEU2-AutoDisc-lb-tg.arn
  }
}

#create Launch configuration for Auto discovery
resource "aws_launch_configuration" "PAADEU2-lc" {
  name_prefix                 = "PAADEU2-lc"
  image_id                    = aws_ami_from_instance.PPADEU2-docker-ami.id
  instance_type               = "t2.medium"
  security_groups             = [aws_security_group.docker_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.PAADEU2_pub_key.key_name
}

#Creating Autoscaling Group 
resource "aws_autoscaling_group" "PAADEU2_ASG" {
  name                      = "PAADEU2_ASG"
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.PAADEU2-lc.name
  vpc_zone_identifier       = [aws_subnet.SnPri1.id, aws_subnet.SnPri2.id]
  target_group_arns         = ["${aws_lb_target_group.PAADEU2-AutoDisc-lb-tg.arn}"]
  tag {
    key                 = "Name"
    value               = "PAADEU2_ASG"
    propagate_at_launch = true
  }
}

#Creating Autoscaling Policy   
resource "aws_autoscaling_policy" "PAADEU2_ASG-pol" {
  name                   = "PAADEU2_ASG-pol"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.PAADEU2_ASG.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40.0
  }
}