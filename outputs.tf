output "my_public_ip" {
  value = "${jsondecode(data.http.my-ip.response_body)["ip"]}"
}

# output "windows_ami" {
#   value = data.aws_ami.Windows_Server
# }

# output "linux_ami" {
#   value = data.aws_ami.Linux_Server
# }

# output "Administrator_Password" {
#     value = rsadecrypt( aws_instance.web-server-instance.password_data , tls_private_key.private-key.private_key_pem)
#     sensitive = true
# }

# Output the generated certificate and private key
# output "private_key" {
#   sensitive = true
#   value = tls_private_key.tls-private-key.private_key_pem
# }

# output "certificate" {
#   value = tls_self_signed_cert.tls-cert.cert_pem
# }

output "certname" {
  value = aws_ec2_client_vpn_endpoint.public_vpn.id
}

# output "openvpn_config_content" {
#   value = data.template_file.openvpn_config.rendered
# }

# output "valid_after" {
#   value = tls_locally_signed_cert.server.validity_start_time
# }

# output "current_time" {
#   value = timestamp()
# }

# output "name" {
#   value = tls_cert_request.server_internal_csr.subject[0].common_name
# }