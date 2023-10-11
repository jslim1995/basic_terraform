variable "prefix" {
  default     = "jinsu_terraform"
  description = "servername prefix"
}

variable "consul_ec2_tag_name" {
  default     = "consul_auto_join"
  description = "consul_auto_join을 위한 태그 명"
}

variable "consul_instance_type" {
  default = "t4g.micro"
  # default = "t2.micro"
  description = "vault instance type"  
}

variable "consul_license" {
  type        = string
  description = "License for the Cousul"
  # default    = "YOUR_DEFAULT_VALUE" # 필요한 경우 기본값 설정
}

variable "pem_key_name" {
  type        = string
  # default     = "jinsu"
  default     = "vbac_pem"
  description = "ec2에 사용되는 pem key 명"
}
