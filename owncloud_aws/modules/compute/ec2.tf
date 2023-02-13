// Attach role to an EC2 instance profile
resource "aws_iam_instance_profile" "ec2-profile" {
  name = "${var.project}-${var.environment}-ec2-profile"
  role = var.iam_role

  tags = {
    Name        = "${var.project}-${var.environment}-ec2-profile"
    Environment = "${var.environment}"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

// EC2 Security Group
resource "aws_security_group" "ec2-sg" {
  name   = "ec2-sg"
  vpc_id = var.vpc_id

  // Allow traffic from the SG itself
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.allowed_sgs
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.allowed_sgs
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
    Name        = "${var.project}-${var.environment}-ec2-sg"
    Environment = "${var.environment}"
  }
}

// EC2 creation
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  subnet_id              = var.allowed_subnets[0]
  iam_instance_profile   = aws_iam_instance_profile.ec2-profile.name
  # user_data              = filebase64("${path.module}/userdata.sh")

  tags = {
    Name        = "${var.project}-${var.environment}-ec2"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group_attachment" "attach-ec2" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.ec2.id
  port             = 80
}