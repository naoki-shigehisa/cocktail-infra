resource "aws_db_subnet_group" "cocktail_db_subnet_group" {
  name        = "${var.r_prefix}-db-subnet-group"
  description = "${var.r_prefix}-db-subnet-group"
  subnet_ids  = [
    aws_subnet.cocktail_public_subnet_1a.id,
    aws_subnet.cocktail_public_subnet_1c.id
  ]

  tags = {
    Name = "${var.r_prefix}-db-subnet-group"
  }
}

resource "aws_db_instance" "cocktail_db" {
  identifier          = "${var.r_prefix}-db"
  engine              = "mysql"
  engine_version      = "8.0.30"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  db_name                = "${var.database_name}"
  username            = "${var.database_username}"
  password            = "${var.database_password}"
  port                = 3306
  multi_az            = false
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.cocktail_sg_db.id]
  db_subnet_group_name   = "${aws_db_subnet_group.cocktail_db_subnet_group.name}"
}
