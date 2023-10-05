# 참고 : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.prefix}_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    security_group_ids = [ "${aws_security_group.all.id}" ]
    subnet_ids = [ aws_subnet.sb.*.id ]
  }
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
# }
