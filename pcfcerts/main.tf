variable "ssl_ca_private_key" {}
variable "ssl_ca_cert" {}
variable "dns_suffix" {}
variable "env_name" {}

resource "tls_cert_request" "ssl_csr" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.ssl_private_key.private_key_pem}"

  dns_names = [
    "*.login.sys.${var.env_name}.${var.dns_suffix}",
    "*.pks.${var.env_name}.${var.dns_suffix}",
    "*.ws.${var.env_name}.${var.dns_suffix}",
  ]

  count = "${length(var.ssl_ca_cert) > 0 ? 1 : 0}"

  subject {
    common_name         = "${var.env_name}.${var.dns_suffix}"
    organization        = "Pivotal"
    organizational_unit = "Cloudfoundry"
    country             = "US"
    province            = "CA"
    locality            = "San Francisco"
  }
}

resource "tls_locally_signed_cert" "ssl_cert" {
  cert_request_pem   = "${tls_cert_request.ssl_csr.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${var.ssl_ca_private_key}"
  ca_cert_pem        = "${var.ssl_ca_cert}"

  count = "${length(var.ssl_ca_cert) > 0 ? 1 : 0}"

  validity_period_hours = 8760 # 1year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "ssl_private_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  count = "${length(var.ssl_ca_cert) > 0 ? 1 : 0}"
}

output "ssl_ca_cert" {
  value     = "${var.ssl_ca_cert}"
}

output "ssl_cert" {
  value     = "${element(concat(tls_locally_signed_cert.ssl_cert.*.cert_pem, list("")),0)}"
}

output "ssl_private_key" {
  value     = "${element(concat(tls_private_key.ssl_private_key.*.private_key_pem, list("")), 0)}"
}
