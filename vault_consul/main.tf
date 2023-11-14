data "template_file" "consul_user_data" {
  template = file(var.architecture == "x86" ? "consul_user_data_x86.tpl" : "consul_user_data_arm.tpl")

  vars = {
    # INSTANCE_ID = aws_instance.vault_raft_amz2_x86[0].id
    tag           = var.consul_tag_name
    consul_license = var.CONSUL_LICENSE
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "consul_amz2" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = var.consul_ec2_count
  subnet_id     = var.subnet_ids[(tonumber(count.index) + 1) % length(var.subnet_az_list)]
  # vpc_security_group_ids = [aws_security_group.all.id]
  security_groups = var.security_group_ids
  key_name        = var.pem_key_name
  tags = {
    Name    = "${var.prefix}-Test-${count.index}"
    auto_join = "${var.consul_tag_name}"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = "10"
    tags = {
      Name = "${var.prefix}_Test_Volume_${count.index}"
    }
  }
  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile = var.consul_iam_instance_profile

  # templatefile function 사용
  # user_data = templatefile("user_data.tpl", {
  #     # dir_name = "${var.prefix}-Test-${count.index}"
  #     INSTANCE_ID = var.INSTANCE_ID2
  #     TAG = var.vault_auto_join
  #     vault_license = var.VAULT_LICENSE
  # })

  user_data = data.template_file.consul_user_data.rendered

  # lifecycle {
  #     ignore_changes = [ user_data ]
  # }
}


data "template_file" "vault_user_data" {
  template = file(var.architecture == "x86" ? "vault_user_data_x86.tpl" : "vault_user_data_arm.tpl")

  vars = {
    # INSTANCE_ID = aws_instance.vault_raft_amz2_x86[0].id
    TAG           = var.vault_tag_name
    vault_license = var.VAULT_LICENSE
  }
}

resource "aws_instance" "vault_amz2" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = var.vault_ec2_count
  subnet_id     = var.subnet_ids[(tonumber(count.index) + 1) % length(var.subnet_az_list)]
  # vpc_security_group_ids = [aws_security_group.all.id]
  security_groups = var.security_group_ids
  key_name        = var.pem_key_name
  tags = {
    Name    = "${var.prefix}-Test-${count.index}"
    auto_join = "${var.vault_tag_name}"
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = "10"
    tags = {
      Name = "${var.prefix}_Test_Volume_${count.index}"
    }
  }
  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile = var.vault_iam_instance_profile

  # templatefile function 사용
  # user_data = templatefile("user_data.tpl", {
  #     # dir_name = "${var.prefix}-Test-${count.index}"
  #     INSTANCE_ID = var.INSTANCE_ID2
  #     TAG = var.vault_auto_join
  #     vault_license = var.VAULT_LICENSE
  # })

  user_data = data.template_file.vault_user_data.rendered

  # lifecycle {
  #     ignore_changes = [ user_data ]
  # }
}
