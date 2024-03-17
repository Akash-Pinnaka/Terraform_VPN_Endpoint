
# Storing tfstate in a S3 backend
terraform {
  backend "s3" {
    bucket         = "tf-state-bucket-akash"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "terraform-state-lock" # Optional: DynamoDB table for state locking
    encrypt        = true
  }
}

# 1. Create VPC
resource "aws_vpc" "VPC-01" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${random_pet.Random_pet[1].id}"
  }
}

# 2. Make Subnets
resource "aws_subnet" "Private-VPC-01" {
  vpc_id            = aws_vpc.VPC-01.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "Private-${random_pet.Random_pet[1].id}"
  }
}

resource "aws_subnet" "Public-VPC-01" {
  vpc_id            = aws_vpc.VPC-01.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "Public-${random_pet.Random_pet[1].id}"
  }
}

# 3. Create Internet Gateway for our VPC

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.VPC-01.id

  tags = {
    Name = "IGW-${random_pet.Random_pet[1].id}"
  }
}

# 4. Create NAT Gateway for the public subnet

resource "aws_nat_gateway" "public-nat" {
  connectivity_type = "public"
  allocation_id     = aws_eip.Nat-ip.id
  subnet_id         = aws_subnet.Public-VPC-01.id

  tags = {
    Name = "Public-NAT-${random_pet.Random_pet[1].id}"
  }

  # # To ensure proper ordering, it is recommended to add an explicit dependency
  # # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


# 6. Create Custom Route Tables for each subnet

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.VPC-01.id

  route {
    cidr_block = var.all_traffic_cidr
    gateway_id = aws_internet_gateway.gw.id
  }
 
  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "public-route-table-${random_pet.Random_pet[1].id}"
  }
}

resource "aws_route_table" "private-route-table" {

  vpc_id = aws_vpc.VPC-01.id

  route {
    cidr_block = var.all_traffic_cidr
    gateway_id = aws_nat_gateway.public-nat.id
  }

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "private-route-table-${random_pet.Random_pet[1].id}"
  }
}

# 7. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Public-VPC-01.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.Private-VPC-01.id
  route_table_id = aws_route_table.private-route-table.id
}
