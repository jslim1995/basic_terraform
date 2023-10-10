variable "prefix" {
  default     = "jinsu_terraform"
  description = "servername prefix"
}
variable "aws_region" {
  default = "ap-northeast-2"
  description = "aws_region"
}

variable "subnet_az_list" {
  type = list(object({
    availability_zone = string
    cidr_block        = string
  }))
  default = [
    # ca-central-1 AZ
    # {
    #   availability_zone = "ca-central-1a"
    #   cidr_block        = "172.164.1.0/24"
    # },
    # {
    #   availability_zone = "ca-central-1b"
    #   cidr_block        = "172.164.2.0/24"
    # },
    {
      availability_zone = "ap-northeast-2a"
      cidr_block        = "172.164.11.0/24"
    },
    {
      availability_zone = "ap-northeast-2b"
      cidr_block        = "172.164.12.0/24"
    },
    {
      availability_zone = "ap-northeast-2c"
      cidr_block        = "172.164.13.0/24"
    },
  ]
  description = "az list"
}

variable "pem_key_name" {
  type        = string
  # default     = "jinsu"
  default     = "vbac_pem"
  description = "ec2에 사용되는 pem key 명"
}
