resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "db-subnet-group"
  subnet_ids  = [aws_subnet.ec2_subnet.id, aws_subnet.rds_subnet.id]
  description = "DB subnet group"
}

# Create the RDS database
resource "aws_db_instance" "rds_database" {
  engine                 = "postgres"
  instance_class         = "db.t3.micro"  # Specify the desired instance class
  allocated_storage      = 5  # Specify the desired storage size
  storage_type           = "standard"
  username               = var.postgres_username  # Specify the desired database username
  password               = var.postgres_password  # Specify the desired database password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot    = true
}
