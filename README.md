# Terraform AWS Infrastructure

Automated AWS infrastructure provisioning using Terraform and GitHub Actions.

## Planned Resources
- VPC and public subnet
- Security group
- S3 bucket
- EC2 instance
- IAM roles for secure access
- AWS Systems Manager Session Manager



# 1. Verify EC2 role
aws sts get-caller-identity

# 2. List bucket objects
aws s3 ls s3://terraform-lab-files-493c12d989418e1ca5606850a0/

# 3. Move to writable directory
cd /tmp

# 4. Create and inspect test file
echo "Terraform EC2 to S3 test" > test.txt
cat test.txt

# 5. Upload to S3
aws s3 cp test.txt s3://terraform-lab-files-493c12d989418e1ca5606850a0/

# 6. Download from S3
aws s3 cp s3://terraform-lab-files-493c12d989418e1ca5606850a0/test.txt downloaded-test.txt

# 7. Verify downloaded content
cat downloaded-test.txt
