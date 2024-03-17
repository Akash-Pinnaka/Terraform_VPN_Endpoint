resource "aws_instance" "db-server-instance" {
  ami                    = var.ami_linux
  instance_type          = var.instance_type_linux
  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.Private-VPC-01.id
  vpc_security_group_ids = [aws_security_group.dbserver_SG.id]
  key_name               = aws_key_pair.key-pair.key_name

  tags = {
    Name = "Linux-server-${random_pet.Random_pet[1].id}"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_instance.web-server-instance ]
}