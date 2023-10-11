data "template_file" "user_data" {
  template = file("user_data.tpl")

  vars = {
    # INSTANCE_ID = aws_instance.vault_raft_amz2_x86[0].id
    TAG           = var.vault_auto_join
  }
}
 
resource "aws_instance" "vault_raft_amz2" {
  ami                    = var.ami_amz2
  instance_type          = var.vault_instance_type
  count                  = var.ec2-count
  subnet_id              = aws_subnet.sb[(tonumber(count.index) + 1) % length(var.subnet_az_list)].id
  # vpc_security_group_ids = [aws_security_group.all.id]
  security_groups = [aws_security_group.all.id]
  key_name               = var.pem_key_name
  tags = {
    Name    = "${var.prefix}-Test-${count.index}"
    service = "${var.vault_auto_join}"
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

  iam_instance_profile = aws_iam_instance_profile.vault_join_profile.name

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
