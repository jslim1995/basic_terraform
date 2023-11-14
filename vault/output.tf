output "prefix_vault" {
  value       = data.vault_kv_secret_v2.prefix.data_json[0]
  description = "servername prefix"
}
