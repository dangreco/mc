provider "vultr" {
  api_key = local.secrets.vultr.api_key
}

provider "cloudflare" {
  api_token = local.secrets.cloudflare.api_token
}
