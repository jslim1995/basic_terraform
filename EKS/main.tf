# 참고 : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.prefix}_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = var.security_group_ids
    subnet_ids              = var.subnet_ids
  }

  # Option
  version = "1.24"
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
  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_role_arn = aws_iam_role.eks_worker_node_role.arn
  subnet_ids    = var.subnet_ids
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  # Option
  node_group_name = "${var.prefix}_eks_node"
  instance_types  = ["t3.small"]

  # remote_access {
  #     ec2_ssh_key = "jinsu"
  #     source_security_group_ids = var.security_group_ids
  # }

  update_config {
    max_unavailable = 1
  }

  version = "1.24"
}
