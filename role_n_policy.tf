# 참고 : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
data "aws_iam_policy_document" "instance_assume_role_policy" {
    statement {
        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

## EC2
# instance에 iam_instance_profile 할당을 위한 resource
resource "aws_iam_instance_profile" "vault_join_profile" {
    name = "vault_join_profile"
    role = aws_iam_role.vault_join_role.name
}

resource "aws_iam_role" "vault_join_role" {
    name = "${var.prefix}_vault_join_role"
    assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
    # managed_policy_arns = [aws_iam_policy.vault_join_policy.arn]

#     assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
}

resource "aws_iam_role_policy" "vault_join_policy" {
    name = "${var.prefix}_vault_join_policy"
    role = aws_iam_role.vault_join_role.id

    # Terraform's "jsonencode" function converts a
    # Terraform expression result to valid JSON syntax.
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
        Action = [
            "ec2:DescribeInstances",
            "iam:GetInstanceProfile",
            "iam:GetUser",
            "iam:ListRoles",
            "iam:GetRole",
            # "sts:AssumeRole"
        ]
        Effect   = "Allow"
        Resource = "*"
        },
    ]
    })
}

## EKS
resource "aws_iam_role" "eks_cluster_role" {
    name = "${var.prefix}_eks_cluster_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole",
                Principal = {
                    Service = "eks.amazonaws.com"
                },
                Effect = "Allow",
            },
        ]
    })
    managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

resource "aws_iam_role" "eks_worker_node_role" {
    name = "${var.prefix}_eks_worker_node_role"
    assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
    managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", 
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", 
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ]
}