output "prefix_vault" {
  value       = data.vault_kv_secret_v2.prefix.data.pre_fix
  description = "servername prefix"
}
