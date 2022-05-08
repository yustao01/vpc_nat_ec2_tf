provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc_module" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name="Production-vpc"
  }
}

resource "aws_subnet" "subnet_1_public" {
  cidr_block = var.public_subnet_1_cidr
  vpc_id     = aws_vpc.vpc_module.id
  availability_zone = "${var.region}a"

  tags = {
    Name="Public-subnet-1"
  }
}

resource "aws_subnet" "subnet_2_public" {
  cidr_block = var.public_subnet_2_cidr
  vpc_id     = aws_vpc.vpc_module.id
  availability_zone = "${var.region}b"

  tags = {
    Name="Public-subnet-2"
  }
}

resource "aws_subnet" "subnet_3_public" {
  cidr_block = var.public_subnet_3_cidr
  vpc_id     = aws_vpc.vpc_module.id
  availability_zone = "${var.region}c"

  tags = {
    Name="Public-subnet-3"
  }
}

resource "aws_subnet" "subnet_1_private" {
  cidr_block = var.private_subnet_1_cidr
  vpc_id     = aws_vpc.vpc_module.id
  availability_zone = "${var.region}a"

  tags = {
    Name="Private-subnet-1"
  }
}

resource "aws_subnet" "subnet_2_private" {
  cidr_block = var.private_subnet_2_cidr
  vpc_id     = aws_vpc.vpc_module.id
  availability_zone = "${var.region}b"

  tags = {
    Name="Private-subnet-2"
  }
}

resource "aws_subnet" "subnet_3_private" {
  cidr_block = var.private_subnet_3_cidr
  vpc_id     = aws_vpc.vpc_module.id
  availability_zone = "${var.region}c"

  tags = {
    Name="Private-subnet-3"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_module.id

  tags = {
    Name="Public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_module.id

  tags = {
    Name="Private-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.subnet_1_public.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.subnet_2_public.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.subnet_3_public.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.subnet_1_private.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.subnet_2_private.id
}

resource "aws_route_table_association" "private_subnet_3_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id = aws_subnet.subnet_3_private.id
}

resource "aws_eip" "elastic_ip_for_NATG" {
  vpc = true
  associate_with_private_ip = var.eip_association_address

  tags = {
    Name="Production-EIP"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip_for_NATG.id
  subnet_id = aws_subnet.subnet_1_public.id

  tags = {
    Name="Production-NATG"
  }
}

resource "aws_route" "nat_gateway_route" {
  route_table_id = aws_route_table.private_route_table.id
  nat_gateway_id = aws_nat_gateway.nat_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc_module.id

  tags = {
    Name="Production-IGW"
  }
}

resource "aws_route" "igw_route" {
  route_table_id = aws_route_table.public_route_table.id
  gateway_id = aws_internet_gateway.internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}
data "aws_ami" "ubuntu_latest" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "my_ec2_instance" {
  ami = data.aws_ami.ubuntu_latest.id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_keypair
  security_groups = [aws_security_group.ec2-security-group.id]
  subnet_id = aws_subnet.subnet_1_public.id

}

resource "aws_security_group" "ec2-security-group" {
  name = "EC2-Instance-SG"
  vpc_id = aws_vpc.vpc_module.id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "vpc_cidr" {
  value = aws_vpc.vpc_module.cidr_block
}

output "public_subnet_1_cidr" {
  value = aws_subnet.subnet_1_public.cidr_block
}

output "private_subnet_1_cidr" {
  value = aws_subnet.subnet_1_private.cidr_block
}

