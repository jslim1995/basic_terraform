provider "aws" {
    region = "ca-central-1"
}


// VPC START
resource "aws_vpc" "main" {
    cidr_block = "172.164.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "${var.prefix}-test"
    }
  
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "sb" {
    count = length(var.subnet_az_list)
    vpc_id = aws_vpc.main.id
    
    availability_zone = var.subnet_az_list[count.index].availability_zone
    cidr_block = var.subnet_az_list[count.index].cidr_block

    map_public_ip_on_launch = true

    tags = {
        Name = "${var.prefix}-subnet-public1-${var.subnet_az_list[count.index].availability_zone}"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.prefix}-igw"
    }
  
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "rtb" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "${var.prefix}-rtb-public"
    }
}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "rtb_sn" {
    count = length(var.subnet_az_list)
    subnet_id = aws_subnet.sb[count.index].id
    route_table_id = aws_route_table.rtb.id
}


// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "all" {
    name = "${var.prefix}-All-allowed"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
  
    tags = {
        Name = "${var.prefix}-sg"
    }
}

// VPC END
