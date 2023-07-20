variable "prefix" {
    default = "jinsu-terraform"
    description = "servername prefix"
}

variable "subnet_az_list" {
    default = toset([
        "ca-central-1a",
        "ca-central-1b"
    ])
    description = "az list"
}

variable "subnet_cidr_list" {
    default = toset([
        "172.164.1.0/24",
        "172.164.2.0/24"
    ])
    description = "cidr list"
}