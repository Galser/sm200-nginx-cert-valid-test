output "certificate" {
  value = "${acme_certificate.certificate.certificate_pem}"
}

output "certificate_url" { 
  value = "${acme_certificate.certificate.certificate_url}"
}
