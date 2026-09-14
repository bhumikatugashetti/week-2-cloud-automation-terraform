resource "aws_db_subnet_group" "db" {
  name = "${var.project_name}-db-subnets"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]
  tags = { Name = "${var.project_name}-db-subnet-group" }
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-postgres"
  engine = "postgres"
  instance_class = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type = "gp3"
  db_name = var.db_name
  username = var.db_username
  password = var.db_password
  port = 5432
  db_subnet_group_name = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false
  multi_az = false
  backup_retention_period = 1
  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately = true

  tags = { Name = "${var.project_name}-postgres" }
}
