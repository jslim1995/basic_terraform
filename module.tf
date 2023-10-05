module "main" {
    source = "./EKS"
    prefix = var.prefix
    security_group_id = aws_security_group.all.id
    subnet_ids = aws_subnet.sb.*.id
}