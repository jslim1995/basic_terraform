locals {
  instance_type = var.architecture == "x86" ? var.instance_type_x86 : var.instance_type_arm
  ami           = var.architecture == "x86" ? var.ami_amz2_x86 : var.ami_amz2_arm
}
