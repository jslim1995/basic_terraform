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

resource "aws_subnet" "ca-central-1a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "172.164.1.0/24"
    availability_zone = var.subnet_az_list

    tags = {
        Name = "${var.prefix}-subnet-public1-${availability_zone}"
    }
}

resource "aws_subnet" "ca-central-1b" {
    vpc_id = aws_vpc.main.id
    cidr_block = "172.164.2.0/24"
    availability_zone = "ca-central-1b"

    tags = {
        Name = "${var.prefix}-subnet-public2-${availability_zone}"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.prefix}-igw"
    }
  
}

resource "aws_route_table" "rtb" {
    vpc_id = aws_vpc.main.id
    route = {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "${var.prefix}-rrb-public"
    }
}

// VPC END
