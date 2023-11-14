output "prefix_vault" {
  value       = data.vault_kv_secret_v2.prefix.data[0]
  description = "servername prefix"
}
