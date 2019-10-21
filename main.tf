resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "andrii@${var.site_domain}"
}

resource "acme_certificate" "certificate" {
  account_key_pem = "${acme_registration.reg.account_key_pem}"
  common_name     = "${var.site_record}.${var.site_domain}"
  #subject_alternative_names = ["www2.example.com"]

  dns_challenge {
    provider = "godaddy"
  }
}