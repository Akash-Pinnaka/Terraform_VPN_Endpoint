data "aws_ami" "Windows_Server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]  
}

data "aws_ami" "Linux_Server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Ubuntu Server 22.04 LTS*"]
  }

}


data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

data "http" "my-ip" {
  url = "https://ipinfo.io/json"
}

data "aws_instance" "get-data" {
  instance_id = aws_instance.web-server-instance.id # using this data source we can get the private IP of instance to use in sec group rules
}


data "aws_vpc" "example" {
  id = aws_vpc.VPC-01.id 
}


data "template_file" "openvpn_config" {
  template = file("client.ovpn.tpl")

  vars = {    
    vpn_port = aws_ec2_client_vpn_endpoint.public_vpn.vpn_port
    server_address = replace(aws_ec2_client_vpn_endpoint.public_vpn.dns_name, "*.", "")
    ca_cert = tls_self_signed_cert.ca-cert.cert_pem
    client_cert = tls_locally_signed_cert.client.cert_pem
    client_key = tls_private_key.client_private_key.private_key_pem
    server_cn = tls_cert_request.server_internal_csr.subject[0].common_name
  }

depends_on = [ local_file.server , local_file.local_ca_cert ,local_file.local-private-key ]
}


