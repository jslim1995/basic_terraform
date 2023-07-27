variable "ec2-count" {
    default = 3
    description = "value"
}

data "template_file" "user_data" {
    template = "${file("shell_script.tpl")}"

    vars = {
        dir_name = "1234"
    }
}

resource "aws_instance" "ec2" {
    ami = "ami-0abc4c35ba4c005ca"
    instance_type = "t2.micro"
    count = var.ec2-count
    subnet_id = aws_subnet.sb[(tonumber(count.index)+1)%length(var.subnet_az_list)].id
    security_groups = [ "${aws_security_group.all.id}" ]
    key_name = "jinsu"
    tags = {
        Name = "${var.prefix}-Test-${count.index}"
    }
    root_block_device {
        volume_type = "gp3"
        volume_size = "10"
    }
    # templatefile function 사용
    # user_data = templatefile("shell_script.tpl", {
    #     dir_name = "${var.prefix}-Test-${count.index}"
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
#       "sudo chown -R ubuntu:ubuntu /var/www/html",
#       "chmod +x *.sh",
#       "PLACEHOLDER=${var.placeholder} WIDTH=${var.width} HEIGHT=${var.height} PREFIX=${var.prefix} ./deploy_app.sh",
#       "sudo apt -y install cowsay",
#       "cowsay Mooooooooooo!",
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = tls_private_key.hashicat.private_key_pem
#       host        = aws_eip.hashicat.public_ip
#     }
#   }
# }

# # tls_private_key https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key.html
# resource "tls_private_key" "hashicat" {
#   algorithm = "ED25519"
# }

# locals {
#   private_key_filename = "${var.prefix}-ssh-key.pem"
# }

# resource "aws_key_pair" "hashicat" {
#   key_name   = local.private_key_filename
#   public_key = tls_private_key.hashicat.public_key_openssh
# }