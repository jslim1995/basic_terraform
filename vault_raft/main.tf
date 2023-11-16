data "template_file" "user_data" {
  template = file(var.architecture == "x86" ? "${path.module}/user_data_x86.tpl" : "${path.module}/user_data_arm.tpl")

  vars = {
    # INSTANCE_ID = aws_instance.vault_raft_amz2_x86[0].id
    TAG           = var.tag_name
    vault_license = var.VAULT_LICENSE
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "vault_raft_amz2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  count         = var.ec2_count
  subnet_id     = var.subnet_ids[(tonumber(count.index) + 1) % length(var.subnet_az_list)]
  # vpc_security_group_ids = [aws_security_group.all.id]
  security_groups = var.security_group_ids
  key_name        = var.pem_key_name
  tags = {
    Name      = "${var.prefix}-Test-${count.index}"
    auto_join = "${var.tag_name}"
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

  iam_instance_profile = var.iam_instance_profile

  # templatefile function 사용
  # user_data = templatefile("user_data.tpl", {
  #     # dir_name = "${var.prefix}-Test-${count.index}"
  #     INSTANCE_ID = var.INSTANCE_ID2
  #     TAG = var.vault_auto_join
  #     vault_license = var.VAULT_LICENSE
  # })

  user_data = data.template_file.user_data.rendered

  # lifecycle {
  #     ignore_changes = [ user_data ]
  # }
}
