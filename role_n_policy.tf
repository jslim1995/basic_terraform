# 참고 : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
data "aws_iam_policy_document" "instance_assume_role_policy" {
    Version = "2012-10-17"
    Statement {
        Effect = "Allow"
        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
        Action = ["sts:AssumeRole"]
    }
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