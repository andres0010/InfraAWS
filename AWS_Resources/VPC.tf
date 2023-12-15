
resource "aws_vpc" "vpcGeneral" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    Name    = "vpcGeneral"
    Project = "Proyectovpc"    
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpcGeneral.id
 tags = {
    Name    = "igw"
    Project = "Proyectovpc"
  }
}

resource "aws_subnet" "subnet_publica_1" {
  vpc_id                  = aws_vpc.vpcGeneral.id
  cidr_block              = var.subnet_cidr_blocks[0]
  availability_zone       = var.region
  tags = {
    Name    = "subnet_publica_1"
    Project = "Proyectovpc"
  }
}

resource "aws_subnet" "subnet_publica_2" {
  vpc_id                  = aws_vpc.vpcGeneral.id
  cidr_block              = var.subnet_cidr_blocks[1]
  availability_zone       = "us-east-1b" # Cambia según tu región
  tags = {
    Name    = "subnet_publica_2"
    Project = "Proyectovpc"
  }
}

resource "aws_route_table" "RTPublica" {
  vpc_id = aws_vpc.vpcGeneral.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name    = "RTPublica"
    Project = "Proyectovpc"
  }
}

resource "aws_route_table_association" "RTPublicaassociation1" {
  subnet_id      = aws_subnet.subnet_publica_1.id
  route_table_id = aws_route_table.RTPublica.id
}
resource "aws_route_table_association" "RTPublicaassociation2" {
  subnet_id      = aws_subnet.subnet_publica_2.id
  route_table_id = aws_route_table.RTPublica.id
}

resource "aws_security_group" "security_group" {
  name        = "security_group"
  description = "Permite trafico de ECS"
  vpc_id      = aws_vpc.vpcGeneral.id # Asociar la VPC al grupo de seguridad

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
