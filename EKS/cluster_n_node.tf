# 참고 : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.prefix}_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    security_group_ids = var.security_group_id
    subnet_ids = var.subnet_ids
  }
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
# }


# 참고 : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
# EKS Node Group
resource "aws_eks_node_group" "eks_node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.prefix}_eks_node"
  node_role_arn   = aws_iam_role.eks_worker_node_role.arn
  subnet_ids      = var.subnet_ids

  instance_types = [ "t3.small" ]
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
}
