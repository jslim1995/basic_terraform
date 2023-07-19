provider "aws" {
    region = "ca-central-1"
}

resource "aws_instance" "ec2" {
    ami = "ami-068d6fd750a3617dd"
    instance_type = "t2.micro"
    vpc_security_group_ids = [ "vpc-02480ac2f085b2cba" ]
}

output "ec2_ip" {
    value = aws_instance.ec2.private_ip
}