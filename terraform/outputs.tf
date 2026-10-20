output "aws_region" {
  description = "AWS region used for this deployment"
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the newly created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "s3_bucket_name" {
  description = "Name of the private S3 bucket"
  value       = aws_s3_bucket.files.id
}

output "ec2_instance_id" {
  description = "ID of the new EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "ec2_iam_role_name" {
  description = "IAM role attached to EC2"
  value       = aws_iam_role.ec2.name
}
# Demo: Testing the Terraform CI/CD workflow.
#new change