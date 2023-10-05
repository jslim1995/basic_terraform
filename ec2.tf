variable "ec2-count" {
    default = 3
    description = "value"
}

variable "ami_amz2_x86" {
    default = "ami-049db1506b2371272"
    description = "ami_amz2_x86"
}

variable "vault_auto_join" {
    default = "vault_auto_join"
    description = "vault_auto_join"
}

variable "VAULT_LICENSE" {
  description = "License for the Vault"
  type        = string
  # default    = "YOUR_DEFAULT_VALUE" # 필요한 경우 기본값 설정
}

data "template_file" "user_data" {
    template = "${file("user_data.tpl")}"

    vars = {
        # INSTANCE_ID = aws_instance.vault_raft_amz2_x86[0].id
        TAG = var.vault_auto_join
        vault_license = var.VAULT_LICENSE
    }
}

resource "aws_instance" "vault_raft_amz2_x86" {
    ami = var.ami_amz2_x86
    instance_type = "t2.micro"
    count = var.ec2-count
    subnet_id = aws_subnet.sb[(tonumber(count.index)+1)%length(var.subnet_az_list)].id
    security_groups = [ "${aws_security_group.all.id}" ]
    key_name = "jinsu"
    tags = {
        Name = "${var.prefix}-Test-${count.index}"
        service = "${var.vault_auto_join}"
    }
    root_block_device {
        volume_type = "gp3"
        volume_size = "10"
    }
    
    iam_instance_profile = aws_iam_role.vault_join_role.arn
    # templatefile function 사용
    # user_data = templatefile("user_data.tpl", {
    #     # dir_name = "${var.prefix}-Test-${count.index}"
    #     INSTANCE_ID = var.INSTANCE_ID2
    #     TAG = var.vault_auto_join
    #     vault_license = var.VAULT_LICENSE
    # })
    
    user_data = data.template_file.user_data.rendered
}


# test 할 것
# null_resource : https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
# resource "null_resource" "configure-cat-app" {
#   depends_on = [aws_eip_association.hashicat]

#   triggers = {
#     build_number = timestamp()
#   }

#   provisioner "file" {
#     source      = "files/"
#     destination = "/home/ubuntu/"

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = tls_private_key.hashicat.private_key_pem
#       host        = aws_eip.hashicat.public_ip
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt -y update",
#       "sleep 15",
#       "sudo apt -y update",
#       "sudo apt -y install apache2",
#       "sudo systemctl start apache2",
#       "sudo chown -R ec2-user:ec2-user /var/www/html",
#       "chmod +x *.sh",
#       "PLACEHOLDER=${var.placeholder} WIDTH=${var.width} HEIGHT=${var.height} PREFIX=${var.prefix} ./deploy_app.sh",
#       "sudo apt -y install cowsay",
#       "cowsay Mooooooooooo!",
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ec2-user"
#       private_key = tls_private_key.hashicat.private_key_pem
#       host        = aws_eip.hashicat.public_ip
#     }
#   }
# }

# # tls_private_key https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key.html
# resource "tls_private_key" "hashicat" {
#   algorithm = "ED25519"
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# locals {
#   private_key_filename = "${var.prefix}-ssh-key.pem"
# }

# resource "aws_key_pair" "hashicat" {
#   key_name   = local.private_key_filename
#   public_key = tls_private_key.hashicat.public_key_openssh
# }