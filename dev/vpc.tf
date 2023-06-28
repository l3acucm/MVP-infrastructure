data "aws_vpc" "default" {
  default = true
}

resource "aws_subnet" "ec2_subnet" {
  cidr_block        = var.ec2_cidr_block
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.aws_region}a"
}

resource "aws_subnet" "rds_subnet" {
  cidr_block        = var.rds_cidr_block
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.aws_region}b"
}

resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Security group for the web instance"

  vpc_id = data.aws_vpc.default.id

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

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db-security-group"
  description = "Security group for the RDS database"

  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.ec2_cidr_block]
  }
}
