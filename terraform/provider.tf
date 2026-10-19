provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "terraform-aws-infrastructure"
      ManagedBy   = "Terraform"
      Environment = "lab"
    }
  }
}