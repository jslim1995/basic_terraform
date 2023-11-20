variable "prefix" {
  default     = "jinsu_terraform"
  description = "servername prefix"
}

variable "consul_ec2_count" {
  default     = 5
  description = "EC2 갯수 설정"
}

variable "consul_tag_name" {
  type        = string
  default     = "consul_auto_join"
  description = "consul_auto_join을 위한 태그 명"
}

variable "CONSUL_LICENSE" {
  type        = string
  description = "License for the Cousul"
  # default    = "YOUR_DEFAULT_VALUE" # 필요한 경우 기본값 설정
}

variable "subnet_az_list" {
  type = list(object({
    availability_zone = string
    cidr_block        = string
  }))
  default = [
    # ca-central-1 AZ
    {
      availability_zone = "ca-central-1a"
      cidr_block        = "172.164.1.0/24"
    },
    {
      availability_zone = "ca-central-1b"
      cidr_block        = "172.164.2.0/24"
    },
    # ap-northeast-2 AZ
    # {
    #   availability_zone = "ap-northeast-2a"
    #   cidr_block        = "172.164.11.0/24"
    # },
    # {
    #   availability_zone = "ap-northeast-2b"
    #   cidr_block        = "172.164.12.0/24"
    # },
    # {
    #   availability_zone = "ap-northeast-2c"
    #   cidr_block        = "172.164.13.0/24"
    # },
  ]
  description = "Subnet AZ 설정 값 목록"
}

variable "vault_ec2_count" {
  default     = 3
  description = "EC2 갯수 설정"
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

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "x86 instance type"
}

variable "ami" {
  type        = string
  default     = "ami-049db1506b2371272"
  description = "ami_amz2_x86"
}

variable "architecture" {
  type = string
  # default     = "arm"
  default     = "x86_64"
  description = "ec2에 사용되는 아키텍쳐 명"
}

variable "subnet_ids" {
  type        = list(string)
  description = "subnet ids"
}

variable "vpc_security_group_ids" {
  description = "aws security group id"
}

variable "security_group_ids" {
  type        = list(string)
  description = "aws security group id"
}

variable "vault_iam_instance_profile" {
  type        = string
  description = "vault_iam_instance_profile"
}

variable "consul_iam_instance_profile" {
  type        = string
  description = "consul_iam_instance_profile"
}
