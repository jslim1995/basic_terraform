output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC id"
}

# output "ec2_ip" {
#     value = aws_instance.vault_raft_amz2_x86.*.private_ip
#     description = "PrivateIP address details"
# }

output "subnet_ids" {
  value = aws_subnet.sb.*.id
}

output "VAULT_LICENSE" {
  value     = var.VAULT_LICENSE
  sensitive = true
}

output "prefix" {
  value       = var.prefix
  description = "servername prefix"
}

output "prefix_vault" {
  sensitive = false
  value = data.vault_kv_secret_v2.prefix
  description = "prefix_vault"
}