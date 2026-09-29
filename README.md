# Terraform AWS Web Server

This project creates a simple **Ubuntu web server on AWS using Terraform**.

You don't need to manually create the server from the AWS Console. Terraform will create the required AWS infrastructure for you.

## What This Project Creates

Terraform creates:

* An AWS VPC
* A public subnet
* An Internet Gateway
* A route table
* A Security Group
* An Ubuntu EC2 instance
* SSH access on port `22`
* Web access on port `80`
* An Apache web server
* A custom `index.html` web page

## Project Structure

```text
web-server-project/
├── main.tf
├── index.html
├── README.md
└── .gitignore
```

---

# Before You Start

You need:

1. An AWS account
2. AWS CLI installed
3. Terraform installed
4. Git installed
5. An SSH key for AWS
6. GitHub account (optional, if you want to upload the project)

You should also make sure your AWS account has permission to create EC2, VPC, Security Group, Internet Gateway and related resources.

---

# Step 1 — Configure AWS

Open your terminal and check that AWS CLI is installed:

```bash
aws --version
```

Then configure AWS:

```bash
aws configure
```

AWS will ask for:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name
Default output format
```

For this project, use:

```text
Default region name: us-east-1
Default output format: json
```

Make sure your AWS credentials have permission to create the required resources.

---

# Step 2 — Check Terraform

Check Terraform:

```bash
terraform version
```

You should see your installed Terraform version.

---

# Step 3 — Create or Use an SSH Key

The EC2 server needs an SSH key so that you can connect to it.

Your Terraform configuration uses:

```hcl
key_name = "linux_practice"
```

This means an AWS EC2 Key Pair named:

```text
linux_practice
```

must exist in the AWS region:

```text
us-east-1
```

If you already have this key pair in AWS, you can continue.

If you don't have one, create an EC2 Key Pair in the AWS Console and download the `.pem` file.

For example:

```text
linux_practice.pem
```

Keep this file private.

**Never upload your `.pem` file to GitHub.**

---

# Step 4 — Put the SSH Key in Your Linux SSH Folder

If your key is called:

```text
linux_practice.pem
```

you can put it in:

```text
~/.ssh/
```

For example:

```bash
mkdir -p ~/.ssh
mv linux_practice.pem ~/.ssh/
```

Then protect the key:

```bash
chmod 400 ~/.ssh/linux_practice.pem
```

You can check it with:

```bash
ls -l ~/.ssh/linux_practice.pem
```

---

# Step 5 — Go to the Project Folder

Open the terminal and go to the project:

```bash
cd ~/terraform/project/web-server-project
```

Check the files:

```bash
ls
```

You should see files such as:

```text
main.tf
index.html
README.md
```

---

# Step 6 — Initialize Terraform

Run:

```bash
terraform init
```

Terraform will download the required AWS provider and prepare the project.

You should see a message similar to:

```text
Terraform has been successfully initialized!
```

---

# Step 7 — Check the Configuration

Run:

```bash
terraform validate
```

If everything is correct, Terraform should show:

```text
Success! The configuration is valid.
```

---

# Step 8 — See What Terraform Will Create

Before creating anything, run:

```bash
terraform plan
```

This is an important step.

Terraform will show you what it plans to create, change, or delete.

Read the plan before continuing.

If Terraform says it will **destroy your existing EC2 server**, stop and review the configuration before running `apply`.

---

# Step 9 — Create the AWS Infrastructure

Run:

```bash
terraform apply
```

Terraform will show the planned changes.

When you see:

```text
Do you want to perform these actions?
```

type:

```text
yes
```

and press Enter.

Terraform will now create the AWS resources.

This may take a few minutes.

---

# Step 10 — Get the Server IP Address

After Terraform finishes, run:

```bash
terraform output
```

If the project doesn't have an output yet, you can get the public IP from AWS Console:

**AWS Console → EC2 → Instances → Your Instance → Public IPv4 address**

For example:

```text
54.123.45.67
```

---

# Step 11 — Open the Website

Open your web browser and enter:

```text
http://YOUR_PUBLIC_IP
```

For example:

```text
http://54.123.45.67
```

You should see the webpage created from:

```text
index.html
```

---

# Step 12 — Connect to the Server Using SSH

You can connect to the Ubuntu server using:

```bash
ssh -i ~/.ssh/linux_practice.pem ubuntu@YOUR_PUBLIC_IP
```

For example:

```bash
ssh -i ~/.ssh/linux_practice.pem ubuntu@54.123.45.67
```

The username for Ubuntu is:

```text
ubuntu
```

Do not use:

```text
ec2-user
```

because this project uses Ubuntu.

---

# Step 13 — Check Apache

After connecting to the server:

```bash
sudo systemctl status apache2
```

You should see that Apache is running.

You can also check:

```bash
curl http://localhost
```

This should display the contents of your web page.

---

# How It Works

The basic process is:

```text
Your Computer
      |
      | Terraform
      v
     AWS
      |
      +-- VPC
      |
      +-- Public Subnet
      |
      +-- Internet Gateway
      |
      +-- Security Group
      |      |
      |      +-- Port 22 (SSH)
      |      +-- Port 80 (HTTP)
      |
      +-- Ubuntu EC2
             |
             +-- Apache Web Server
             |
             +-- index.html
```

---

# Important: Understand Terraform Changes

Terraform keeps track of the infrastructure it creates using a **state file**.

For example:

```text
terraform.tfstate
```

Do not manually delete or edit this file unless you understand the consequences.

Before changing `main.tf`, always run:

```bash
terraform plan
```

Pay special attention to:

```text
destroy
```

or:

```text
must be replaced
```

If Terraform says an EC2 instance **must be replaced**, it means the current server may be deleted and a new server created.

For example, changing certain EC2 settings such as the SSH key can cause an EC2 replacement.

Always review the plan before typing:

```text
yes
```

---

# Updating the Website

If you change:

```text
index.html
```

you may need to apply the Terraform configuration again depending on how the file is being deployed.

Run:

```bash
terraform plan
```

Then:

```bash
terraform apply
```

---

# Destroy Everything

When you no longer need the AWS infrastructure, you can remove the resources created by Terraform.

First check what will be removed:

```bash
terraform plan -destroy
```

If you are sure you want to delete everything created by this Terraform project:

```bash
terraform destroy
```

Terraform will ask for confirmation.

Type:

```text
yes
```

This can delete the AWS resources managed by this Terraform configuration.

**Be very careful with this command.**

---

# GitHub Upload

If you want to upload this project to GitHub:

```bash
git init
git add .
git commit -m "Initial Terraform AWS web server project"
```

Add your GitHub repository:

```bash
git remote add origin git@github.com:YOUR_USERNAME/terraform-aws-web-server.git
```

Then:

```bash
git branch -M main
git push -u origin main
```

---

# Files You Should NOT Upload to GitHub

Never upload private credentials or Terraform state files.

Do not upload:

```text
*.pem
terraform.tfstate
terraform.tfstate.backup
.terraform/
*.tfvars
```

The included `.gitignore` file should help prevent these files from being committed.

---

# Troubleshooting

## Website Does Not Open

Check:

1. EC2 instance is running.
2. EC2 has a public IP.
3. Security Group allows TCP port `80`.
4. Apache is running.

SSH into the server:

```bash
ssh -i ~/.ssh/linux_practice.pem ubuntu@YOUR_PUBLIC_IP
```

Then:

```bash
sudo systemctl status apache2
```

---

## SSH Does Not Work

Check:

* The EC2 instance is running.
* Port `22` is allowed in the Security Group.
* You are using the correct `.pem` file.
* The AWS key pair matches the `key_name` in Terraform.
* You are using the Ubuntu username:

```text
ubuntu
```

Try:

```bash
chmod 400 ~/.ssh/linux_practice.pem
```

Then:

```bash
ssh -i ~/.ssh/linux_practice.pem ubuntu@YOUR_PUBLIC_IP
```

---

## Terraform Wants to Destroy the EC2

Do not immediately type:

```text
yes
```

First run:

```bash
terraform plan
```

Look for:

```text
must be replaced
```

Terraform may need to replace an EC2 instance when certain settings that require replacement are changed.

If you are unsure, stop and review the plan before applying it.

---

# Useful Commands

### Initialize

```bash
terraform init
```

### Validate

```bash
terraform validate
```

### Preview changes

```bash
terraform plan
```

### Create/update infrastructure

```bash
terraform apply
```

### Show Terraform outputs

```bash
terraform output
```

### Show resources managed by Terraform

```bash
terraform state list
```

### Destroy infrastructure

```bash
terraform destroy
```

---

# Result

After completing the steps, you will have:

* An Ubuntu EC2 server on AWS
* A public IP address
* Apache web server
* A custom HTML page
* SSH access
* Infrastructure created and managed with Terraform

The main benefit is that the AWS infrastructure can be created again using the Terraform configuration instead of manually creating every resource through the AWS Console.
