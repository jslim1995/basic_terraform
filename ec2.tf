variable "ec2-count" {
    default = 3
    description = "value"
}

resource "template_file" "user_data" {
    template = "${file("shell_script.tpl")}"

    vars {
        dir_name = "${aws_instance.ec2.tags}"
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
    user_data = "${template_file.user_data.rendered}"
}

