variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "ami" {
  description = "AMI for EC2 instances"
  type        = string
  default     = "ami-0a1235697f4afa8a4" # replace with current Amazon Linux 2 AMI
}
