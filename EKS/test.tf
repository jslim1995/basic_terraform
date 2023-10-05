data "aws_eks_cluster" "name" {
    name = "${var.prefix}_eks_cluster"
}

output "name" {
    value = data.aws_eks_cluster.name.name
}