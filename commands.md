# Terraform AWS Infrastructure — Session-wise Command Book
 

> **How to use this file**
> - Run PowerShell commands on your Windows computer unless a section explicitly says “inside EC2”.
> - Run Terraform commands from the `terraform` directory.
> - Run Linux commands only inside the EC2 Session Manager terminal.
> - `terraform apply` and especially `terraform destroy` can change real AWS resources. Review plans carefully.

---

## Session 1 — Check required tools (Windows PowerShell)

Open PowerShell and run:

```powershell
terraform version
git --version
aws --version
where.exe terraform
where.exe git
where.exe aws
```

- **Command:** `terraform version`
  **What it does:** Shows the installed Terraform version.
- **Command:** `git --version`
  **What it does:** Shows the installed Git version.
- **Command:** `aws --version`
  **What it does:** Shows the installed AWS CLI version.
- **Command:** `where.exe terraform`
  **What it does:** Shows which Terraform executable Windows will use.
- **Command:** `where.exe git`
  **What it does:** Shows the Git executable path.
- **Command:** `where.exe aws`
  **What it does:** Shows the AWS CLI executable path.

If a command is not recognized, install the required tool and reopen PowerShell before continuing.

## Session 2 — Open the repository and inspect Git

```powershell
cd "C:\Users\patil\Desktop\terraform-aws-infrastructure"
git status
git branch
git remote -v
git log -5 --oneline
git remote get-url origin
```

- **Command:** `cd "..."`
  **What it does:** Moves into the local project folder.
- **Command:** `git status`
  **What it does:** Shows the current branch and working-tree changes.
- **Command:** `git branch`
  **What it does:** Lists local branches; `*` marks the current branch.
- **Command:** `git remote -v`
  **What it does:** Shows configured remote URLs.
- **Command:** `git log -5 --oneline`
  **What it does:** Shows the five latest commits in compact form.
- **Command:** `git remote get-url origin`
  **What it does:** Displays the URL configured as `origin`.

Expected repository URL:

```text
https://github.com/sarveshhatii/terraform-aws-infrastructure.git
```

The existing branches recorded for this project are `main` and `feature/terraform-aws-infra`. Continue with the existing feature branch; do not create an unnecessary third branch.

## Session 3 — Select and verify the local AWS CLI profile

The recorded local profile is `terraform-infra`, associated with IAM user `terraform-infra-provisioner`.

```powershell
$env:AWS_PROFILE = "terraform-infra"
aws sts get-caller-identity
aws configure list
aws configure list-profiles
aws sts get-caller-identity --profile terraform-infra
```

- **Command:** `$env:AWS_PROFILE = "terraform-infra"`
  **What it does:** Selects this profile for the current PowerShell session.
- **Command:** `aws sts get-caller-identity`
  **What it does:** Shows the AWS account and identity used by the command.
- **Command:** `aws configure list`
  **What it does:** Shows which profile, region, and credential sources the CLI is using.
- **Command:** `aws configure list-profiles`
  **What it does:** Lists configured AWS CLI profile names.
- **Command:** `aws sts get-caller-identity --profile terraform-infra`
  **What it does:** Runs the identity check with this profile explicitly.

The recorded account ID is `020671572525`; verify it before running changes. The `$env:AWS_PROFILE` setting applies only to the current PowerShell session. It does not change GitHub Actions' identity or EC2's instance role.

## Session 4 — Check region and existing AWS resources

```powershell
aws configure get region --profile terraform-infra
aws ec2 describe-vpcs --region ap-south-1 --query "Vpcs[].VpcId" --output table
aws ec2 describe-instances --region ap-south-1 --query "Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]" --output table
aws s3 ls
```

- **Command:** `aws configure get region ...`
  **What it does:** Shows the configured region for the profile.
- **Command:** `aws ec2 describe-vpcs ...`
  **What it does:** Lists VPC IDs in the selected region.
- **Command:** `aws ec2 describe-instances ...`
  **What it does:** Lists instance ID, state, and public IP where present.
- **Command:** `aws s3 ls`
  **What it does:** Attempts to list all buckets visible to the identity.

**Note:** `aws s3 ls` may return `AccessDenied` if the identity is not allowed to list all account buckets. This does not automatically mean access to a specific bucket is broken. Test a known bucket directly instead.

Recorded resource identifiers (verify in AWS before using them):

```text
VPC:              vpc-026d97416110e79e7
Internet Gateway: igw-01d06fbb0c91c1719
Subnet:           subnet-085c601fde2d16646
Route table:      rtb-0f4685bfdaac2d38f
Security group:   sg-089aca6844865e18a
EC2 instance:     i-012541be8c9edb91a
Application S3:   terraform-lab-files-493c12d989418e1ca5606850a0
Terraform state:  terraform-aws-infra-state-020671572525-ap-south-1
```

## Session 5 — Locate and enter the Terraform directory

```powershell
cd "C:\Users\patil\Desktop\terraform-aws-infrastructure\terraform"
Get-ChildItem
Get-ChildItem *.tf
```

- **Command:** `cd "...\\terraform"`
  **What it does:** Moves to the directory containing this project's Terraform files.
- **Command:** `Get-ChildItem`
  **What it does:** Lists files and folders in the current directory.
- **Command:** `Get-ChildItem *.tf`
  **What it does:** Lists Terraform configuration files in the current directory.

Terraform loads all `.tf` files in the same directory as one configuration. It does not automatically load `.tf` files inside a child folder as part of the parent configuration.

## Session 6 — Initialize, format, and validate Terraform

Run from the `terraform` directory:

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
```

- **Command:** `terraform init`
  **What it does:** Initializes the working directory, downloads required providers, and configures the backend.
- **Command:** `terraform fmt -check -recursive`
  **What it does:** Checks Terraform formatting without changing files.
- **Command:** `terraform validate`
  **What it does:** Checks configuration syntax and internal consistency.

If you intentionally want Terraform to format files:

```powershell
terraform fmt -recursive
terraform validate
```

- **Command:** `terraform fmt -recursive`
  **What it does:** Formats Terraform files in the current directory and subdirectories.
- **Command:** `terraform validate`
  **What it does:** Checks the configuration again after formatting.

Review the resulting Git diff before committing. If `terraform init` fails, check provider access, backend configuration, network access, and AWS permissions. Do not delete the state file to resolve an initialization error.

## Session 7 — Inspect Terraform workspace, state, and outputs

```powershell
terraform workspace show
terraform state list
terraform output
terraform output -json
```

- **Command:** `terraform workspace show`
  **What it does:** Shows the current Terraform workspace.
- **Command:** `terraform state list`
  **What it does:** Lists resource addresses tracked in the current state.
- **Command:** `terraform output`
  **What it does:** Displays configured Terraform outputs.
- **Command:** `terraform output -json`
  **What it does:** Displays outputs in JSON format for programmatic use.

To inspect one resource:

```powershell
terraform state show <resource_address>
```

Replace `<resource_address>` with an exact address returned by `terraform state list`. Do not guess the address.

Recorded remote state settings:

```text
Bucket: terraform-aws-infra-state-020671572525-ap-south-1
Key:    terraform-aws-infrastructure/terraform.tfstate
Region: ap-south-1
Lock:   use_lockfile = true
```

If you intentionally change backend settings, Terraform may need reconfiguration:

```powershell
terraform init -reconfigure
```

Use `-reconfigure` only when you intend to change/reconfirm backend settings. Protect the state bucket and never casually delete or overwrite the state.

## Session 8 — Create and review a Terraform plan

First confirm the identity and directory:

```powershell
aws sts get-caller-identity
terraform workspace show
terraform state list
```

Then create and inspect a plan:

```powershell
terraform plan
terraform plan -out=tfplan
terraform show tfplan
```

- **Command:** `terraform plan`
  **What it does:** Previews the changes Terraform proposes to make.
- **Command:** `terraform plan -out=tfplan`
  **What it does:** Saves a plan to a local file named `tfplan`.
- **Command:** `terraform show tfplan`
  **What it does:** Displays the saved plan for review.

Before applying, look for unexpected resource replacement or deletion, especially for EC2, S3 buckets, IAM roles, and networking. A plan is a preview; it does not change resources.

## Session 9 — Apply reviewed Terraform changes

For a saved plan:

```powershell
terraform apply tfplan
```

Or use interactive apply:

```powershell
terraform apply
```

- **Command:** `terraform apply tfplan`
  **What it does:** Applies the saved plan after it has been reviewed.
- **Command:** `terraform apply`
  **What it does:** Creates a fresh plan, displays it, and asks for confirmation before applying.

Only apply after confirming the intended AWS identity, workspace, and changes. A result of `0 added, 0 changed, 0 destroyed` can mean the infrastructure already matches the configuration; it does not prove new resources were created in that run.

If the saved plan is no longer needed, remove the local file:

```powershell
Remove-Item .\tfplan -ErrorAction SilentlyContinue
```

This removes `tfplan` if present. Do not commit plan files; they may contain sensitive values.

## Session 10 — Understand and inspect Terraform files

A maintainable layout can separate services into files in the same `terraform` directory:

```text
terraform/
  provider.tf or versions.tf
  backend.tf
  variables.tf
  terraform.tfvars
  vpc.tf
  security-group.tf
  iam.tf
  ec2.tf
  s3.tf
  outputs.tf
```

- **Command:** `provider.tf` / `versions.tf`
  **What it does:** Provider and version requirements.
- **Command:** `backend.tf`
  **What it does:** Remote Terraform state configuration.
- **Command:** `variables.tf`
  **What it does:** Variable declarations and types.
- **Command:** `terraform.tfvars`
  **What it does:** Values for variables; do not put secrets here.
- **Command:** `vpc.tf`
  **What it does:** VPC, subnet, gateway, and routes.
- **Command:** `security-group.tf`
  **What it does:** Security group and traffic rules.
- **Command:** `iam.tf`
  **What it does:** IAM role, permissions policies, and instance profile.
- **Command:** `ec2.tf`
  **What it does:** EC2 instance configuration.
- **Command:** `s3.tf`
  **What it does:** S3 buckets and settings.
- **Command:** `outputs.tf`
  **What it does:** Useful outputs such as IDs, names, and addresses.

To inspect the files:

```powershell
Get-ChildItem *.tf
Get-Content .\s3.tf
Get-Content .\ec2.tf
Get-Content .\iam.tf
Get-Content .\outputs.tf
```

- **Command:** `Get-ChildItem *.tf`
  **What it does:** Lists `.tf` files.
- **Command:** `Get-Content .\s3.tf`
  **What it does:** Prints the contents of `s3.tf`.
- **Command:** `Get-Content .\ec2.tf`
  **What it does:** Prints the contents of `ec2.tf`.
- **Command:** `Get-Content .\iam.tf`
  **What it does:** Prints the contents of `iam.tf`.
- **Command:** `Get-Content .\outputs.tf`
  **What it does:** Prints the contents of `outputs.tf`.

Moving a resource between `.tf` files in the same directory normally does not change its Terraform address. Renaming resources or moving them into modules can change addresses and may require careful state migration.

## Session 11 — Optional: add a second S3 bucket

The existing S3 resource is named `aws_s3_bucket.files`. Keep it. If you want a second bucket, add another resource with a different local name in `s3.tf`. Example:

```hcl
resource "aws_s3_bucket" "backup_files" {
  bucket_prefix = "${var.project_name}-backup-"

  tags = {
    Name = "${var.project_name}-backup"
  }
}

resource "aws_s3_bucket_public_access_block" "backup_files" {
  bucket = aws_s3_bucket.backup_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backup_files" {
  bucket = aws_s3_bucket.backup_files.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

This is an optional example; it is not proof that a second bucket has already been created. Compare with your existing `s3.tf` before editing.

After editing, run:

```powershell
terraform fmt -recursive
terraform validate
terraform plan
```

- **Command:** `terraform fmt -recursive`
  **What it does:** Formats the edited Terraform code.
- **Command:** `terraform validate`
  **What it does:** Checks configuration syntax and consistency.
- **Command:** `terraform plan`
  **What it does:** Shows the proposed new bucket and related settings, plus any other detected changes.

Review the entire plan. Confirm it adds the intended bucket and does not replace or delete the existing bucket. Only then run:

```powershell
terraform apply
```

After confirming the reviewed plan, verify the new bucket in AWS Console → S3. Creating a bucket does not automatically grant EC2 access to it; update the EC2 role permissions in `iam.tf` if the instance needs access.

## Session 12 — Git: check branch, stage, commit, and push

Run from the repository root:

```powershell
cd "C:\Users\patil\Desktop\terraform-aws-infrastructure"
git status
git switch feature/terraform-aws-infra
git pull --ff-only origin feature/terraform-aws-infra
```

- **Command:** `git status`
  **What it does:** Shows changes and current branch.
- **Command:** `git switch feature/terraform-aws-infra`
  **What it does:** Switches to the existing feature branch.
- **Command:** `git pull --ff-only origin feature/terraform-aws-infra`
  **What it does:** Updates the branch only if it can fast-forward cleanly.

Stage only the file(s) you intend to commit. For README documentation:

```powershell
git add README.md
git diff --cached
git diff --cached --check
git commit -m "docs: update project documentation"
git push origin feature/terraform-aws-infra
```

For an S3 Terraform change, stage that file instead:

```powershell
git add terraform/s3.tf
git diff --cached
git diff --cached --check
git commit -m "feat: add backup S3 bucket"
git push origin feature/terraform-aws-infra
```

- **Command:** `git add ...`
  **What it does:** Stages the selected file(s).
- **Command:** `git diff --cached`
  **What it does:** Shows the staged changes before commit.
- **Command:** `git diff --cached --check`
  **What it does:** Checks staged changes for whitespace errors.
- **Command:** `git commit -m "..."`
  **What it does:** Saves staged changes in a local commit.
- **Command:** `git push origin ...`
  **What it does:** Pushes the branch to GitHub.

Use only the commit message appropriate to the change. Do not stage both examples blindly. If Git reports an LF/CRLF warning, it is usually a line-ending notice; check `git status` and the diff.

## Session 13 — Create a pull request and run CI

On GitHub:

1. Open the project repository.
2. Choose **Compare & pull request** for `feature/terraform-aws-infra`.
3. Set **base** to `main` and **compare** to `feature/terraform-aws-infra`.
4. Review the changed files and diff.
5. Wait for required Terraform CI checks.
6. Merge only after reviewing the changes and checks.

Recorded workflow files:

```text
.github/workflows/terraform-ci.yml
.github/workflows/terraform-deploy.yml
```

Local checks useful before pushing:

```powershell
git status
git diff
git diff --check
```

- **Command:** `git status`
  **What it does:** Shows uncommitted changes.
- **Command:** `git diff`
  **What it does:** Shows unstaged changes.
- **Command:** `git diff --check`
  **What it does:** Checks unstaged changes for whitespace errors.

CI typically checks formatting, validation, and a Terraform plan according to the YAML. A pull request is a proposed change; CI does not normally apply infrastructure unless an apply step is explicitly configured.

## Session 14 — Merge and verify the main branch

After checks pass and the PR is approved, merge it in GitHub. Then update your local main branch:

```powershell
git switch main
git pull --ff-only origin main
git log -5 --oneline
git status
```

- **Command:** `git switch main`
  **What it does:** Switches to the local main branch.
- **Command:** `git pull --ff-only origin main`
  **What it does:** Updates local main if fast-forward is possible.
- **Command:** `git log -5 --oneline`
  **What it does:** Shows recent commits, including the merge/change if in the latest five.
- **Command:** `git status`
  **What it does:** Confirms the working-tree state.

If you continue working, switch back to the existing feature branch and fetch updates:

```powershell
git switch feature/terraform-aws-infra
git fetch origin
```

`git fetch origin` downloads remote branch updates without merging them into your current branch.

## Session 15 — Understand deployment workflow / CD

The deployment workflow is `.github/workflows/terraform-deploy.yml`. It is configured for matching changes pushed to `main` and supports a manual trigger if configured. Whether it runs depends on the workflow's `on:` triggers and any `paths` filters.

Typical sequence:

1. A feature branch is pushed and a PR is opened.
2. CI runs on a matching PR.
3. The PR is merged to `main`.
4. Matching changes to `main` can trigger deployment.
5. The workflow assumes the AWS role using GitHub OIDC.
6. Terraform runs the steps configured in the workflow.
7. Inspect GitHub → Actions → the workflow run → logs and final result.

The recorded deployment role is `GitHubActionsTerraformInfraRole`; the GitHub Environment is `terraform-production`. A `main` branch restriction was configured. Required reviewer approval was not confirmed as enabled, so do not claim a manual approval gate is active until it is configured and tested.

A README-only change may not trigger CI/CD if the path filters exclude README. That is often intentional. If documentation changes should run CI, add `README.md` to the CI workflow's path filters. Do not add it to the deployment filter just to force an AWS deployment.

## Session 16 — Understand GitHub OIDC and IAM roles

OIDC allows GitHub Actions to request an identity token. AWS checks the token claims against the IAM role's trust policy. If the conditions match, AWS STS supplies temporary credentials.

Recorded identities/roles:

- GitHub deployment role: `GitHubActionsTerraformInfraRole`
- EC2 role: `terraform-lab-ec2-s3-ssm-role`
- Local CLI profile: `terraform-infra`

These are separate identities. The local command below shows only the local CLI identity:

```powershell
aws sts get-caller-identity
```

To verify the GitHub Actions identity, inspect the workflow logs. Do not assume the local AWS identity is the one used by GitHub.

OIDC reduces the need for long-lived AWS keys stored as GitHub secrets. A restrictive trust policy and least-privilege permissions are still required.

## Session 17 — Connect to EC2 with Session Manager and verify role

Open AWS Console → EC2 → Instances → select the project instance → **Connect** → **Session Manager** → **Connect**.

Run these commands **inside the EC2 Linux terminal**, not Windows PowerShell:

```bash
aws sts get-caller-identity
```

- **Command:** `aws sts get-caller-identity`
  **What it does:** Shows the AWS identity the EC2 shell's AWS CLI is using.

The recorded result contained an assumed-role ARN similar to:

```text
arn:aws:sts::020671572525:assumed-role/terraform-lab-ec2-s3-ssm-role/i-012541be8c9edb91a
```

This confirms use of the instance role's temporary credentials. Do not place long-lived AWS access keys on EC2.

## Session 18 — Test EC2-to-S3 access with a text file

Run inside the EC2 Session Manager Linux terminal. The recorded application bucket is `terraform-lab-files-493c12d989418e1ca5606850a0`; verify it before use.

```bash
aws s3 ls s3://terraform-lab-files-493c12d989418e1ca5606850a0/
cd /tmp
echo "Terraform EC2 to S3 test" > test.txt
cat test.txt
aws s3 cp test.txt s3://terraform-lab-files-493c12d989418e1ca5606850a0/
aws s3 cp s3://terraform-lab-files-493c12d989418e1ca5606850a0/test.txt downloaded-test.txt
cat downloaded-test.txt
```

- **Command:** `aws s3 ls s3://BUCKET/`
  **What it does:** Lists objects in the named bucket if authorized.
- **Command:** `cd /tmp`
  **What it does:** Moves to a writable temporary directory.
- **Command:** `echo "..." > test.txt`
  **What it does:** Creates/overwrites `test.txt` with the message.
- **Command:** `cat test.txt`
  **What it does:** Displays the original file.
- **Command:** `aws s3 cp test.txt s3://BUCKET/`
  **What it does:** Uploads the file to S3.
- **Command:** `aws s3 cp s3://BUCKET/test.txt downloaded-test.txt`
  **What it does:** Downloads the object under a new local filename.
- **Command:** `cat downloaded-test.txt`
  **What it does:** Displays the downloaded content for comparison.

Expected content:

```text
Terraform EC2 to S3 test
```

The recorded round-trip test succeeded. This demonstrates the instance could perform the allowed bucket/object operations using its role; it does not mean every S3 action is allowed.

Optional cleanup after collecting evidence, and only if you confirm it is your demo object:

```bash
aws s3 rm s3://terraform-lab-files-493c12d989418e1ca5606850a0/test.txt
```

This deletes only the named object. Do not delete other objects; the bucket previously contained `s3-test.txt`.

## Session 19 — Check a specific bucket from Windows

Run in PowerShell with the intended profile:

```powershell
$env:AWS_PROFILE = "terraform-infra"
aws s3 ls s3://terraform-lab-files-493c12d989418e1ca5606850a0/
aws s3api list-objects-v2 --bucket terraform-lab-files-493c12d989418e1ca5606850a0 --region ap-south-1
```

- **Command:** `$env:AWS_PROFILE = ...`
  **What it does:** Selects the local CLI profile for this session.
- **Command:** `aws s3 ls s3://BUCKET/`
  **What it does:** Lists objects in the specified bucket if authorized.
- **Command:** `aws s3api list-objects-v2 ...`
  **What it does:** Uses the lower-level S3 API to list objects and return structured data.

The local IAM user and EC2 role can have different permissions. A command working on EC2 may not work locally, and vice versa.

## Session 20 — Troubleshooting checks

### AWS identity and profile

```powershell
aws sts get-caller-identity
aws configure list
```

Shows which principal and configuration the local AWS CLI is using.

### Terraform formatting, validation, and plan

```powershell
terraform fmt -check -recursive
terraform validate
terraform plan
```

Checks formatting, configuration consistency, and proposed infrastructure changes.

### Git state

```powershell
git status
git diff
git diff --cached
git log -5 --oneline
```

Shows current changes, unstaged/staged differences, and recent commits.

### EC2 instance state

```powershell
aws ec2 describe-instances --instance-ids i-012541be8c9edb91a --region ap-south-1 --query "Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]" --output table
```

Shows the selected instance ID, state, and public IP if present. Verify the ID before use.

### Specific S3 bucket

```powershell
aws s3 ls s3://terraform-lab-files-493c12d989418e1ca5606850a0/
```

If `AccessDenied` occurs, identify the principal first and inspect the relevant IAM and bucket policies. Do not add broad permissions as the first fix.

## Session 21 — Destroy only when explicitly approved

**Do not run destroy just to test a command.** The application bucket contains/contained test objects, and the Terraform state bucket must be preserved.

First verify identity, workspace, state, and the full destroy plan:

```powershell
aws sts get-caller-identity
terraform workspace show
terraform state list
terraform plan -destroy
```

- **Command:** `aws sts get-caller-identity`
  **What it does:** Verifies the current AWS principal.
- **Command:** `terraform workspace show`
  **What it does:** Shows the current workspace.
- **Command:** `terraform state list`
  **What it does:** Shows managed resource addresses.
- **Command:** `terraform plan -destroy`
  **What it does:** Previews resources Terraform would destroy; it does not destroy them.

Only after explicit approval, reviewing all affected resources, and preserving needed data:

```powershell
terraform destroy
```

`terraform destroy` removes resources managed by the current configuration/state after confirmation. Read the plan carefully before typing `yes`. The project history recorded here does not confirm that destroy was completed.

## Session 22 — Final verification checklist

From repository root:

```powershell
git status
git log -5 --oneline
```

From the Terraform directory:

```powershell
terraform fmt -check -recursive
terraform validate
terraform plan
```

Confirm manually:

- [ ] GitHub pull-request CI passed.
- [ ] Deployment workflow succeeded on `main`.
- [ ] Deployment logs show the expected assumed AWS role.
- [ ] EC2 is reachable through Session Manager.
- [ ] EC2 can list the specific application bucket.
- [ ] EC2 uploaded and downloaded the test object successfully.
- [ ] Evidence screenshots are saved.
- [ ] README and cost estimate are reviewed.
- [ ] Manual approval is tested if required.
- [ ] Any extra bucket is only described as deployed after a successful apply and AWS verification.
- [ ] Destroy is reported as planned or completed accurately.

## Important safety notes

- Verify account, region, resource IDs, bucket names, workspace, and state before running commands.
- Never commit `.tfstate`, `tfplan`, credentials, private keys, or secrets.
- Do not paste AWS access keys into screenshots or documentation.
- Keep the remote state bucket separate from application resources and protect it from deletion.
- Commands in this guide include inspection, optional cleanup, and optional extensions. Their presence does not prove each action was performed.
