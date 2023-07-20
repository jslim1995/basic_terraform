variable "prefix" {
    default = "jinsu-terraform"
    description = "servername prefix"
}

variable "subnet_az_list" {
    type = list(object({
        availability_zone = string
        cidr_block = string
    }))
    default = [ {
        availability_zone = "ca-central-1a"
        cidr_block = "172.164.1.0/24"
    }, {
        availability_zone = "ca-central-1b"
        cidr_block = "172.164.2.0/24"
    } ]
    description = "az list"
}

