variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project identifier used for naming resources"
  type        = string
  default     = "terraform-lab"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "Optional IPv4 CIDR allowed for SSH; leave empty to disable SSH ingress"
  type        = string
  default     = ""
}