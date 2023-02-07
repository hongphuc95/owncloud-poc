resource "aws_security_group" "ssm-sg" {
  name   = "${var.project}-${var.environment}-ssm-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-ssm-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_vpc_endpoint" "ssm-endpoint" {
  vpc_id             = aws_vpc.vpc.id
  subnet_ids         = aws_subnet.private_subnet.*.id
  security_group_ids = ["${aws_security_group.ssm-sg.id}"]
  vpc_endpoint_type  = "Interface"
  service_name       = "com.amazonaws.${var.region}.ssm"

  private_dns_enabled = true

  tags = {
    Name        = "${var.project}-${var.environment}-ssm-endpoint"
    Environment = "${var.environment}"
  }
}

resource "aws_vpc_endpoint" "ssmmessages-endpoint" {
  vpc_id             = aws_vpc.vpc.id
  subnet_ids         = aws_subnet.private_subnet.*.id
  security_group_ids = ["${aws_security_group.ssm-sg.id}"]
  vpc_endpoint_type  = "Interface"
  service_name       = "com.amazonaws.${var.region}.ssmmessages"

  private_dns_enabled = true

  tags = {
    Name        = "${var.project}-${var.environment}-ssmmessages-endpoint"
    Environment = "${var.environment}"
  }
}