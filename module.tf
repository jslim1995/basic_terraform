module "main" {
    source = "./EKS"

    count = 1

    prefix = var.prefix
    security_group_ids = [ "${aws_security_group.all.id}" ]
    subnet_ids = aws_subnet.sb.*.id
}