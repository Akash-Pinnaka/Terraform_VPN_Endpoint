# Generate a private key for CA
resource "tls_private_key" "ca-private-key" {
  algorithm = "RSA"
}


# Generate a self-signed  CA certificate
resource "tls_self_signed_cert" "ca-cert" {

  is_ca_certificate     = true
  private_key_pem = tls_private_key.ca-private-key.private_key_pem

  subject {
    common_name  = "akash.com"
    organization = "IndusValley"
  }

  validity_period_hours = 8760
  
  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing"
  ]
}


# Private key for server
resource "tls_private_key" "server_private_key" {
  algorithm = "RSA"
}

#Create Certificate Signing Request
resource "tls_cert_request" "server_internal_csr" {

  private_key_pem = tls_private_key.server_private_key.private_key_pem


  subject {
    common_name  = "akash.pinnaka"
    organization = "IndusValley"
  }

}

# Sign Server Certificate by Private CA 

resource "tls_locally_signed_cert" "server" {
  // CSR 
  cert_request_pem = tls_cert_request.server_internal_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = tls_private_key.ca-private-key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.ca-cert.cert_pem

  validity_period_hours = 43800

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]
}


# Private key for Client
resource "tls_private_key" "client_private_key" {
  algorithm = "RSA"
}

#Create Certificate Signing Request
resource "tls_cert_request" "client_internal_csr" {

  private_key_pem = tls_private_key.client_private_key.private_key_pem


  subject {
    common_name  = "akash.pinnaka"
    organization = "IndusValley"
  }

}

# Sign Server Certificate by Private CA 

resource "tls_locally_signed_cert" "client" {
  // CSR 
  cert_request_pem = tls_cert_request.client_internal_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = tls_private_key.ca-private-key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.ca-cert.cert_pem

  validity_period_hours = 43800

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
  ]
}


# To avoid cases where acm is imported to aws before certificate validity_start_time begins
resource "time_sleep" "wait_for_time" {
  depends_on = [tls_locally_signed_cert.server , tls_locally_signed_cert.client]

  // Calculate the duration until the validity_start_time for accurate time
  # create_duration = "${timestamp(tls_locally_signed_cert.server.validity_start_time) - timestamp()}"

  
  create_duration = "1s"
}


resource "aws_acm_certificate" "server_cert" {
  private_key       = tls_private_key.server_private_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.ca-cert.cert_pem

  # depends_on = [ tls_locally_signed_cert.server , tls_cert_request.server_internal_csr  ]
  depends_on = [time_sleep.wait_for_time]
}

resource "aws_acm_certificate" "client_cert" {
  private_key       = tls_private_key.client_private_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.client.cert_pem
  certificate_chain = tls_self_signed_cert.ca-cert.cert_pem

  depends_on = [time_sleep.wait_for_time]
}
