
resource "godaddy_domain_record" "our_site_record" {
  domain = var.site_domain

  record {
    name = var.site_record
    type = "A"
    data = "${aws_instance.nginxweb.public_ip}"
    ttl  = 600
  }

  record {
    data     = "@"
    name     = "www"
    priority = 0
    ttl      = 3600
    type     = "CNAME"
  }

  record {
    data     = "_domainconnect.gd.domaincontrol.com"
    name     = "_domainconnect"
    priority = 0
    ttl      = 3600
    type     = "CNAME"
  }
}