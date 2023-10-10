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
  description = "Subnet AZ 설정 값 목록"
}

variable "ec2-count" {
  default     = 3
  description = "EC2 갯수 설정"
}

variable "ami_amz2" {
  default     = "ami-043a1babe609d076d"
  # default     = "ami-049db1506b2371272"
  description = "ami_amz2_arm"
}

# variable "ami_amz2" {
#   default     = "ami-049db1506b2371272"
#   description = "ami_amz2_x86"
# }

variable "vault_auto_join" {
  default     = "vault_auto_join_1010"
  description = "vault_auto_join을 위한 태그 명"
}

variable "vault_instance_type" {
  default = "t4g.micro"
  # default = "t2.micro"
  description = "vault instance type"  
}

variable "VAULT_LICENSE" {
  type        = string
  description = "License for the Vault"
  # default    = "YOUR_DEFAULT_VALUE" # 필요한 경우 기본값 설정
}

variable "pem_key_name" {
  type        = string
  # default     = "jinsu"
  default     = "vbac_pem"
  description = "ec2에 사용되는 pem key 명"
}
