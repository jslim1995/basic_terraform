provider "aws" {
    region = "ca-central-1"
}

resource "aws_instance" "ec2" {
    ami = "ami-0abc4c35ba4c005ca"
    instance_type = "t2.micro"
    subnet_id = "subnet-0e3124a38d1724f4c"
    security_groups = [ "sg-03af6a452c389eb45" ]
    key_name = "jinsu"
    tagtags = {
        Name = "Terraform_Test"
    }
    root_block_device {
        volume_type = "gp3"
        volume_size = "10"
    }
    user_data = <<EOF
      #!/bin/bash
      sudo echo test | tee test.txt
EOF
}

output "ec2_ip" {
    value = aws_instance.ec2.private_ip
}