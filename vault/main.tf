# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
provider "vault" {
  address = "http://jinsu.inside-vault.com"
  # address    = "http://3.96.222.156:8200"
  token      = "hvs.CAESIKHvxKvbXRVr1i-_DOdp9lDVUUOcNRhHGzSLpLYK2CtJGigKImh2cy5YdUdFejY3ckhJemhkTHdrZXM4enJUcGUuUWJMckMQ1sAB"
  token_name = "terraform"
  #   auth_login {
  #     path      = "auth/userpass/login/:username"
  #     namespace = "tf"
  #     # use_root_namespace = true
  #   }
}

# kv enable
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2
resource "vault_mount" "kvv2" {
  #   namespace   = "tf"
  path        = "client_count_test"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

# kv write
# resource "vault_kv_secret_v2" "example" {
# #   namespace = "tf"
#   mount     = "secret"
#   name      = "value"
#   #   cas                 = 1
#   #   delete_all_versions = true
#   data_json = jsonencode(
#     {
#       zip = "zap2",
#       foo = "bar2"
#     }
#   )
# }

# kv read
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret_v2
data "vault_kv_secret_v2" "prefix" {
  #   namespace = "tf"
  mount = "secret"
  name  = "value"
  #   version   = "2"
}
