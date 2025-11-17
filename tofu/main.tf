resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "vultr_ssh_key" "my_ssh_key" {
  name    = "minecraft-mc-key"
  ssh_key = tls_private_key.this.public_key_openssh
}

data "vultr_os" "this" {
  filter {
    name   = "name"
    values = ["Debian 13 x64 (trixie)"]
  }
}

data "vultr_region" "this" {
  filter {
    name   = "city"
    values = ["Toronto"]
  }
  filter {
    name   = "country"
    values = ["CA"]
  }
}

data "vultr_plan" "this" {
  filter {
    name   = "id"
    values = ["voc-m-1c-8gb-50s-amd"]
  }
}

resource "vultr_reserved_ip" "this" {
  region  = data.vultr_region.this.id
  ip_type = "v4"
}

resource "vultr_instance" "this" {
  plan   = data.vultr_plan.this.id
  region = data.vultr_region.this.id
  os_id  = data.vultr_os.this.id

  hostname = "dangreco-mc"
  label    = "dangreco-mc-instance"
  tags     = ["minecraft"]

  ssh_key_ids      = [vultr_ssh_key.my_ssh_key.id]
  enable_ipv6      = true
  reserved_ip_id   = vultr_reserved_ip.this.id
  activation_email = false
}



locals {
  inventory = {
    all = {
      hosts = {
        dangreco-mc = {
          ansible_host               = vultr_reserved_ip.this.subnet
          ansible_user               = "root"
          ansible_python_interpreter = "/usr/bin/python3"
        }
      }
    }
  }
}

resource "local_sensitive_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.yml"
  content = replace(
    replace(
      yamlencode(local.inventory),
      "/((?:^|\\n)[\\s-]*)\"([\\w-]+)\":/",
      "$1$2:"
    ),
    "{}",
    ""
  )
}

data "cloudflare_zone" "this" {
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_dns_record" "this" {
  zone_id = var.cloudflare_zone_id
  name    = "mc.${data.cloudflare_zone.this.name}"
  type    = "A"
  content = vultr_reserved_ip.this.subnet
  ttl     = 300
  proxied = false
  comment = "Managed by OpenTofu"
}
