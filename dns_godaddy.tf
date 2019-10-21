
resource "godaddy_domain_record" "our_site_record" {
  domain = var.site_domain

  record {
    name = var.site_record
    type = "A"
    data = "192.168.1.2"
    ttl  = 3600
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