
output "public_ip" {
  value = "${aws_instance.nginxweb.public_ip}"
}

output "public_dns" {
  value = "${aws_instance.nginxweb.public_dns}"
}