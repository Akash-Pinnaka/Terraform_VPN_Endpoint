resource "aws_ec2_client_vpn_endpoint" "public_vpn" {
  description            = "Client VPN"
  server_certificate_arn = aws_acm_certificate.server_cert.arn
  client_cidr_block      = "10.0.16.0/22"
  split_tunnel = true
  vpc_id = aws_vpc.VPC-01.id

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.server_cert.arn
  }

  connection_log_options {
    enabled               = false
  }

  dns_servers = ["10.0.0.2", "8.8.8.8"]

  tags = {
    Name = "public_vpn_${random_pet.Random_pet[1].id}"
  }
}

# ADD authorization rule to allow all users
resource "aws_ec2_client_vpn_authorization_rule" "example" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.public_vpn.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_network_association" "example" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.public_vpn.id
  subnet_id              = aws_subnet.Public-VPC-01.id

}
