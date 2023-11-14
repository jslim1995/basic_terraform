provider "vault" {
  address    = "http://jinsu.inside-vault.com:80"
  token      = "hvs.CAESIBDiNwQkE9npx-bz5v1aYDMKi7LfxNAuAjbRMG3Tu4GzGigKImh2cy5KU3ZPRFNXR1NLVUdsVXU5TVJIYmRsNFcuUWJMckMQyKAB"
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
