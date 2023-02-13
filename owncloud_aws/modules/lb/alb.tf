// Load Balancer Security Group
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Load Balancer Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.allowed_cidr_blocks
    ipv6_cidr_blocks = var.allowed_ipv6_cidr_blocks
    description      = "Allow HTTPS"
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allowed_cidr_blocks
    ipv6_cidr_blocks = var.allowed_ipv6_cidr_blocks
    description      = "Allow HTTP"
  }

  # Allow all outbound traffic.
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-alb-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_alb" "alb" {
  name            = "alb"
  security_groups = ["${aws_security_group.alb-sg.id}"]
  subnets         = var.subnets_id
  tags = {
    Name        = "${var.project}-${var.environment}-alb"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "group" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}

# resource "aws_alb_listener" "listener_https" {
#   load_balancer_arn = "${aws_alb.alb.arn}"
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "${var.certificate_arn}"
#   default_action {
#     target_group_arn = "${aws_alb_target_group.group.arn}"
#     type             = "forward"
#   }
# }
