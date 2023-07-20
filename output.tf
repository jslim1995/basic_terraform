output "vpc_id" {
    value = aws_vpc.main.id
    description = "VPC id"
}

output "ec2_ip" {
    value = aws_instance.ec2.*.private_ip
    description = "PrivateIP address details"
}