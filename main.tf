resource "aws_key_pair" "tf200-nginxweb-key" {
  key_name   = "tf200-nginxweb-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "nginxweb" {
  ami                    = var.amis[var.region]
  instance_type          = "${var.instance_type}"
  subnet_id              = var.subnet_ids[var.region]
  vpc_security_group_ids = [var.vpc_security_group_ids[var.region]]
  key_name               = "${aws_key_pair.tf200-nginxweb-key.id}"

  connection {
    user        = "ubuntu"
    type        = "ssh"
    private_key = "${file("~/.ssh/id_rsa")}"
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "sudo ufw allow 'Nginx Full'",
      "sudo ufw delete allow 'Nginx HTTP'"
    ]
  }

  provisioner "file" {
    content     = <<EOT
    server {
        server_name cert-test-a.guselietov.com;
        listen 80;

        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        location / {
                try_files $uri $uri/ =404;
        }

    }    
    EOT
    destination = "/tmp/${var.site_record}.${var.site_domain}.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/${var.site_record}.${var.site_domain}.conf /etc/nginx/sites-available/",
      "sudo ln -s /etc/nginx/sites-available/${var.site_record}.${var.site_domain}.conf /etc/nginx/sites-enabled/",
      "sudo add-apt-repository ppa:certbot/certbot -y",
      "sudo apt install python-certbot-nginx -y",
    ]
  }

  tags = {
    "Name"      = "web-nginx",
    "andriitag" = "true",
  }
}
resource "null_resource" "nginxweb-cert" {
 # depends_on because we need first GoDaddy to register 
 # DNS record and cert bot going to use that for challenge/response
  depends_on = [ godaddy_domain_record.our_site_record ]

  connection {
    user        = "ubuntu"
    type        = "ssh"
    private_key = "${file("~/.ssh/id_rsa")}"
    host        = "${aws_instance.nginxweb.public_ip}"
  }

  provisioner "remote-exec" {
    
    inline = [
      "sleep 30",
      "sudo certbot --nginx -d cert-test-a.guselietov.com --non-interactive --agree-tos -m andrii@guselietov.com",
      "sudo tar -czvf /tmp/lte.tgz /etc/letsencrypt/",
      "sudo tar -czvf /tmp/nginx.tgz /etc/nginx"
    ]
  }
}