# 9. Create Security Group to allow port 22, 80, 443, 3389

resource "aws_security_group" "webserver_SG" {
  name   = "allow_web_traffic"
  vpc_id = aws_vpc.VPC-01.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.all_traffic_cidr]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_traffic_cidr]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [format("%s/32", data.external.myipaddr.result.ip)]
    # cidr_blocks = [format("%s/32", data.http.my=ipaddr.ip)]
  }
  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [format("%s/32", data.external.myipaddr.result.ip)]
    # cidr_blocks = [format("%s/32", data.external.myipaddr.ip)]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_traffic_cidr]
  }
  tags = {
    Name = "webserver_SG"
  }
}



resource "aws_security_group" "dbserver_SG" {
  name   = "allow_ssh_traffic"
  vpc_id = aws_vpc.VPC-01.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [format("%s/32", data.aws_instance.get-data.private_ip)] # allows access only from our bastion host
  }
  ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [format("%s/32", data.aws_instance.get-data.private_ip)] # allows access only from our bastion host
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_traffic_cidr]
  }
  tags = {
    Name = "dbserver_SG"
  }

  depends_on = [ aws_instance.web-server-instance ]
}