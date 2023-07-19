provider "aws" {
    region = "ca-central-1"
}

resource "aws_instance" "ec2" {
    ami = "ami-068d6fd750a3617dd"
    instance_type = "t2.micro"
    subnet_id = "subnet-0e3124a38d1724f4c"
}

output "ec2_ip" {
    value = aws_instance.ec2.private_ip
}