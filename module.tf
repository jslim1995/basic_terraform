module "eks" {
  source = "./EKS"

  count = 0

  prefix             = var.prefix
  security_group_ids = ["${aws_security_group.all.id}"]
  subnet_ids         = aws_subnet.sb.*.id
  pem_key_name       = var.pem_key_name
}

module "vault_raft" {
  source = "./vault_raft"

  count = 1

  tag_name             = "vault_auto_join"
  subnet_ids           = aws_subnet.sb.*.id
  iam_instance_profile = aws_iam_instance_profile.vault_join_profile.name
  vpc_security_group_ids = aws_security_group.all.id
  security_group_ids   = ["${aws_security_group.all.id}"]
  architecture         = var.architecture
  ami                  = local.ami
  instance_type        = local.instance_type
  subnet_az_list       = var.subnet_az_list
  prefix               = var.prefix
  VAULT_LICENSE        = var.VAULT_LICENSE
  pem_key_name         = var.pem_key_name
}

module "vault_consul" {
  source = "./vault_consul"

  count = 0

  subnet_ids             = aws_subnet.sb.*.id
  vpc_security_group_ids = aws_security_group.all.id
  security_group_ids     = ["${aws_security_group.all.id}"]
  # architecture         = "x86_64"
  ami            = local.ami
  instance_type  = local.instance_type
  subnet_az_list = var.subnet_az_list
  prefix         = var.prefix
  VAULT_LICENSE  = var.VAULT_LICENSE
  # pem_key_name         = var.pem_key_name
  CONSUL_LICENSE              = var.CONSUL_LICENSE
  vault_iam_instance_profile  = aws_iam_instance_profile.vault_join_profile.name
  consul_iam_instance_profile = aws_iam_instance_profile.vault_join_profile.name

}

module "vault" {
  source = "./vault"
}
