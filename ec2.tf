# data "template_file" "user_data" {
#   template = file("user_data.tpl")

#   vars = {
#     # INSTANCE_ID = aws_instance.vault_raft_amz2_x86[0].id
#     TAG           = var.vault_auto_join
#     vault_license = var.VAULT_LICENSE
#   }
# }

# resource "aws_instance" "vault_raft_amz2" {
#   ami                    = var.ami_amz2
#   instance_type          = var.vault_instance_type
#   count                  = var.ec2-count
#   subnet_id              = aws_subnet.sb[(tonumber(count.index) + 1) % length(var.subnet_az_list)].id
#   # vpc_security_group_ids = [aws_security_group.all.id]
#   security_groups = [aws_security_group.all.id]
#   key_name               = var.pem_key_name
#   tags = {
#     Name    = "${var.prefix}-Test-${count.index}"
#     service = "${var.vault_auto_join}"
#   }
#   root_block_device {
#     volume_type = "gp3"
#     volume_size = "10"
#     tags = {
#       Name = "${var.prefix}_Test_Volume_${count.index}"
#     }
#   }
#   credit_specification {
#     cpu_credits = "standard"
#   }

#   iam_instance_profile = aws_iam_instance_profile.vault_join_profile.name

#   # templatefile function 사용
#   # user_data = templatefile("user_data.tpl", {
#   #     # dir_name = "${var.prefix}-Test-${count.index}"
#   #     INSTANCE_ID = var.INSTANCE_ID2
#   #     TAG = var.vault_auto_join
#   #     vault_license = var.VAULT_LICENSE
#   # })

#   user_data = data.template_file.user_data.rendered

#   # lifecycle {
#   #     ignore_changes = [ user_data ]
#   # }
# }


# # resource "aws_instance" "test" {
# #     ami = var.ami_amz2_x86
# #     instance_type = "t2.micro"
# #     availability_zone = var.subnet_az_list[0].availability_zone
# #     subnet_id = aws_subnet.sb[0].id
# #     vpc_security_group_ids = [ aws_security_group.all.id ]
# #     key_name = "jinsu"
# #     tags = {
# #         Name = "${var.prefix}-Test"
# #         service = "${var.vault_auto_join}"
# #     }
# #     # root_block_device {
# #     #     volume_type = "gp3"
# #     #     volume_size = "10"
# #     #     tags = {
# #     #         Name = "${var.prefix}_Test_Volume"
# #     #     }
# #     # }
# # }

# # test 할 것
# # null_resource : https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
# # resource "null_resource" "configure-cat-app" {
# #   depends_on = [aws_eip_association.hashicat]

# #   triggers = {
# #     build_number = timestamp()
# #   }

# #   provisioner "file" {
# #     source      = "files/"
# #     destination = "/home/ubuntu/"

# #     connection {
# #       type        = "ssh"
# #       user        = "ubuntu"
# #       private_key = tls_private_key.hashicat.private_key_pem
# #       host        = aws_eip.hashicat.public_ip
# #     }
# #   }

# # # https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec
# #   provisioner "remote-exec" {
# #     inline = [
# #       "sudo apt -y update",
# #       "sleep 15",
# #       "sudo apt -y update",
# #       "sudo apt -y install apache2",
# #       "sudo systemctl start apache2",
# #       "sudo chown -R ec2-user:ec2-user /var/www/html",
# #       "chmod +x *.sh",
# #       "PLACEHOLDER=${var.placeholder} WIDTH=${var.width} HEIGHT=${var.height} PREFIX=${var.prefix} ./deploy_app.sh",
# #       "sudo apt -y install cowsay",
# #       "cowsay Mooooooooooo!",
# #     ]

# #     connection {
# #       type        = "ssh"
# #       user        = "ec2-user"
# #       private_key = tls_private_key.hashicat.private_key_pem
# #       host        = aws_eip.hashicat.public_ip
# #     }
# #   }
# # }

# tls_private_key https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key.html
resource "tls_private_key" "hashicat" {
#   algorithm = "ED25519"
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
resource "aws_key_pair" "hashicat" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.hashicat.public_key_openssh
}

data "tls_public_key" "pemfile" {
  private_key_pem = tls_private_key.hashicat.private_key_pem
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# resource "aws_instance" "pem_key_check_instance" {
#   ami           = local.ami
#   instance_type = local.instance_type
# #   count         = 1
# #   subnet_id     = aws_subnet.sb.*.id[0]
#   vpc_security_group_ids = [aws_security_group.all.id]
#   key_name        = aws_key_pair.hashicat.key_name
#   tags = {
#     Name    = "${var.prefix}-remote-exec-test"
#   }
#   root_block_device {
#     volume_type = "gp3"
#     volume_size = "10"
#     tags = {
#       Name = "${var.prefix}_Test_Volume"
#     }
#   }
# #   credit_specification {
# #     cpu_credits = "standard"
# #   }

# #   iam_instance_profile = aws_iam_instance_profile.vault_join_profile.name

#   # templatefile function 사용
#   # user_data = templatefile("user_data.tpl", {
#   #     # dir_name = "${var.prefix}-Test-${count.index}"
#   #     INSTANCE_ID = var.INSTANCE_ID2
#   #     TAG = var.vault_auto_join
#   #     vault_license = var.VAULT_LICENSE
#   # })

#   # user data
#   # user_data = data.template_file.user_data.rendered

#   # lifecycle {
#   #     ignore_changes = [ user_data ]
#   # }
# }