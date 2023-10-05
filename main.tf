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

    map_public_ip_on_launch = true  // 퍼블릭 IP 주소 자동 할당

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

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl
resource "aws_network_acl" "acl" {
    vpc_id = aws_vpc.main.id

    # Vault reporting ip start
    egress {
        protocol   = "tcp"
        rule_no    = 80
        action     = "deny"
        cidr_block = "100.20.70.12/32"
        from_port  = 443
        to_port    = 443
    }

    egress {
        protocol   = "tcp"
        rule_no    = 81
        action     = "deny"
        cidr_block = "35.166.5.222/32"
        from_port  = 443
        to_port    = 443
    }

    egress {
        protocol   = "tcp"
        rule_no    = 82
        action     = "deny"
        cidr_block = "23.95.85.111/32"
        from_port  = 443
        to_port    = 443
    }

    egress {
        protocol   = "tcp"
        rule_no    = 83
        action     = "deny"
        cidr_block = "44.215.244.1/32"
        from_port  = 443
        to_port    = 443
    }
    # Vault reporting ip end
    
    egress {
        protocol   = "all"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }

    ingress {
        protocol   = "all"
        rule_no    = 100
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }

    tags = {
        Name = "${var.prefix}-acl"
    }
}

resource "aws_network_acl_association" "main" {
    count = length(aws_subnet.sb)
    network_acl_id = aws_network_acl.acl.id
    subnet_id      = aws_subnet.sb[count.index].id
}




// VPC END
