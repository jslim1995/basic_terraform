# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
provider "vault" {
    address    = "http://jinsu.inside-vault.com"
  # address    = "http://3.96.222.156:8200"
  token      = "hvs.CAESICF2PJhCahhLNgy8cC9kEeh4GnX7ESwgiR0ABtBUDTdkGigKImh2cy5HRUQ3YTQzM2VpdGZtNmd1WE9xeHBrZGwuUWJMckMQ2KMB"
  token_name = "terraform"
  #   auth_login {
  #     path      = "auth/userpass/login/:username"
  #     namespace = "tf"
  #     # use_root_namespace = true
  #   }
}

# kv write
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2
# resource "vault_mount" "kvv2" {
# #   namespace   = "tf"
#   path        = "secret"
#   type        = "kv"
#   options     = { version = "2" }
#   description = "KV Version 2 secret engine mount"
# }

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
  mount     = "secret"
  name      = "value"
  #   version   = "2"
}
