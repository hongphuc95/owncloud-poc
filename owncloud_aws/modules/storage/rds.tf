// AWS Security Group
resource "aws_security_group" "db-sg" {
  name   = "rds-sg"
  vpc_id = var.vpc_id

  // Allow traffic from the SG itself
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
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
    Name        = "${var.project}-${var.environment}-rds-sg"
    Environment = "${var.environment}"
  }
}

// RDS Subnet Group
resource "aws_db_subnet_group" "subnet-group" {
  name       = "rds-subnet-group"
  subnet_ids = var.allowed_subnets

  tags = {
    Name        = "${var.project}-${var.environment}-rds-subnet-group"
    Environment = "${var.environment}"
  }
}

resource "aws_db_instance" "rds" {
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]
  db_subnet_group_name   = aws_db_subnet_group.subnet-group.name
  skip_final_snapshot    = true

  tags = {
    Name        = "${var.project}-${var.environment}-rds"
    Environment = "${var.environment}"
  }
}