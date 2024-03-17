# 9. Create Network ACL

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.VPC-01.id
  subnet_ids = [ aws_subnet.Private-VPC-01.id , aws_subnet.Public-VPC-01.id ]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.all_traffic_cidr
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.all_traffic_cidr
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.all_traffic_cidr
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.all_traffic_cidr
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = var.all_traffic_cidr
    from_port  = 8082
    to_port    = 8082
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = var.all_traffic_cidr
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 600
    action     = "allow"
    cidr_block = var.all_traffic_cidr
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 700
    action     = "allow"
    cidr_block = var.all_traffic_cidr
    from_port  = 3306
    to_port    = 3306
  }

  tags = {
    Name = "VPC-${random_pet.Random_pet[1].id}"
  }
}