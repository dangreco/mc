output "ip" {
  value     = vultr_reserved_ip.this
  sensitive = true
}

output "instance" {
  value     = vultr_instance.this
  sensitive = true
}

output "tls_private_key" {
  value     = tls_private_key.this
  sensitive = true
}
