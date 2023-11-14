provider "vault" {
#   address    = "http://jinsu.inside-vault.com:80"
  address    = "http://3.96.222.156:8200"
  token      = "hvs.CAESICdREjsQL3w3ueiAEA4wvUYT3wE07jnvpWxbsUyF70nOGigKImh2cy5nSm9YVjluM3R3YmJKY3pLS2FGNkFkaUQuUWJMckMQ36AB"
  token_name = "terraform"
  auth_login {
    path      = "auth/token/login"
    namespace = "tf"
    # use_root_namespace = true
  }
}

# kv write
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2

# kv read
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2
data "vault_kv_secret_v2" "prefix" {
  namespace = "tf"
  mount     = "secret"
  name      = "value"
  version   = "2"
}
