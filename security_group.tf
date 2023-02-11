# アプリ全体用
resource "aws_security_group" "cocktail_sg_app" {
  name        = "${var.r_prefix}-sg-app"
  description = "${var.r_prefix}-sg-app"
  vpc_id      = "${aws_vpc.cocktail_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.r_prefix}-sg-app"
  }
}

# ロードバランサー用
resource "aws_security_group" "cocktail_sg_alb" {
  name        = "${var.r_prefix}-sg-alb"
  description = "${var.r_prefix}-sg-alb"
  vpc_id      = "${aws_vpc.cocktail_vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.r_prefix}-sg-alb"
  }
}

# データベース用
resource "aws_security_group" "cocktail_sg_db" {
  name        = "${var.r_prefix}-sg-db"
  description = "${var.r_prefix}-sg-db"
  vpc_id      = "${aws_vpc.cocktail_vpc.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.cocktail_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.r_prefix}-sg-db"
  }
}

# ec2用
resource "aws_security_group" "cocktail_sg_ec2" {
  name        = "${var.r_prefix}-sg-ec2"
  description = "${var.r_prefix}-sg-ec2"
  vpc_id      = "${aws_vpc.cocktail_vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.r_prefix}-sg-ec2"
  }
}
