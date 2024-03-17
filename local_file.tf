
resource "local_file" "rdp_file" {
  filename = "${path.module}/.keys/instance-${formatdate("YYYYMMDDHHmmss", timestamp())}.rdp"
  content  = <<-RDP_CONTENT
    auto connect:i:1
    full address:s:${aws_eip.webserver-ip.public_ip}
    username:s:Administrator
    audiomode:i:2
    audiocapturemode:i:1
  RDP_CONTENT
  depends_on = [ aws_instance.web-server-instance, aws_eip.webserver-ip ]
}

resource "null_resource" "run_rdp_file" {
  provisioner "local-exec" {
    command = "start ${local_file.rdp_file.filename}"
  }
  triggers = {
    # Add any dependencies here, for example, the null_resource.rdp_execution.id
    always_run = "${timestamp()}"
  }

  depends_on = [ local_file.rdp_file , local_file.windows-password]
}

resource "local_file" "local-private-key" {
  content = tls_private_key.private-key.private_key_pem

  filename = "${path.module}/.keys/local_tf_private_key_${random_pet.Random_pet[1].id}.pem"
  file_permission = "0400"
}

resource "local_file" "local-public-key" {
    content = tls_private_key.private-key.public_key_pem

    filename = "${path.module}/.keys/local_tf_public_key_${random_pet.Random_pet[1].id}.pem"
    file_permission = "0400"
}


resource "local_file" "windows-password" {
    content = rsadecrypt((aws_instance.web-server-instance.password_data) , tls_private_key.private-key.private_key_pem)
    filename = "${path.module}/.keys/${random_pet.Random_pet[1].id}-windows-password"
}

resource "local_file" "local_ca_key" {
  content  = tls_private_key.ca-private-key.private_key_pem
  filename = "${path.module}/.certs/local_ca_key.key"
}

# store CA
resource "local_file" "local_ca_cert" {
  content  = tls_self_signed_cert.ca-cert.cert_pem
  filename = "${path.module}/.certs/local_ca_cert.crt"
}

resource "local_file" "local_server_private_key" {
  content  = tls_private_key.server_private_key.private_key_pem
  filename = "${path.module}/.certs/local_server_private_key.key"
}

resource "local_file" "server" {
  content  = tls_locally_signed_cert.server.cert_pem
  filename = "${path.module}/.certs/signed_certificate.crt"
}


resource "local_file" "ovpn_file" {
  content = data.template_file.openvpn_config.rendered

  filename = "${path.module}/.certs/client_config.ovpn"
}