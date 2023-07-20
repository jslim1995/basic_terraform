variable "ec2-count" {
    default = 1
    description = "value"
}



resource "aws_instance" "ec2" {
    ami = "ami-0abc4c35ba4c005ca"
    instance_type = "t2.micro"
    count = var.ec2-count
    subnet_id = aws_subnet.sb[length(var.subnet_az_list)%(tonumber(count.index)+1)].id
    security_groups = [ "${aws_security_group.all.id}" ]
    key_name = "jinsu"
    tags = {
        Name = "${var.prefix}-Test-${count.index}"
    }
    root_block_device {
        volume_type = "gp3"
        volume_size = "10"
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo echo "test" | tee test.txt
                sudo mkdir /home/ubuntu/test123
                sudo mkdir /home/ubuntu/${var.prefix}
                EOF
}

