resource "aws_vpc" "rds_vpc_instance" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "capstone-project1"
  }
}

resource "aws_subnet" "rds_subnet1" {
  vpc_id            = aws_vpc.rds_vpc_instance.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "eu-north-1a"
}

resource "aws_subnet" "rds_subnet2" {
  vpc_id            = aws_vpc.rds_vpc_instance.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "eu-north-1b"
}

resource "aws_internet_gateway" "access_public" {
  vpc_id = aws_vpc.rds_vpc_instance.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.rds_vpc_instance.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.access_public.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.rds_subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.rds_subnet2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "rds_sg" {
  name   = "redshift-securitygroup"
  vpc_id = aws_vpc.rds_vpc_instance.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "capstone1-rds-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet1.id, aws_subnet.rds_subnet2.id]

  tags = {
    Name = "capstone1-rds-subnet-group"
  }
}

resource "aws_db_instance" "postgres_rds" {
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "16.3"
  instance_class          = "db.t3.micro"         
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.postgres16"  
  publicly_accessible     = true                 
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
}
