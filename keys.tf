resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "aws_key_pair" "key-pair" {
  key_name = "aws-key-pair-${random_pet.Random_pet[1].id}"
  public_key = tls_private_key.private-key.public_key_openssh

  tags = {
    Name = "aws-key-pair-${random_pet.Random_pet[1].id}"
  }
}
