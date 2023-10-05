module "main" {
    source = "./EKS"
    subnet_ids = aws_subnet.sb.*.id
}