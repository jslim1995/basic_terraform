output "vpc_id" {
    value = aws_vpc.main.id
    description = "VPC id"
}

output "ec2_ip" {
    value = aws_instance.ec2.*.private_ip
    description = "PrivateIP address details"
}

output "subnet_list" {
    value = aws_subnet.sb.*.id
}

output "VAULT_LICENSE" {
    value = var.VAULT_LICENSE
    sensitive   = true
}