resource "aws_eip" "Nat-ip" {
  domain = "vpc"
  
}

resource "aws_eip" "webserver-ip" {
  instance = aws_instance.web-server-instance.id # Associate the EIP with the EC2 instance
}