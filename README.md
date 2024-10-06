# Terraform Project for AWS Subnet Creation

This Terraform project provisions AWS resources, specifically creating a subnet with a CIDR block `192.168.24.0/24` within a specified VPC.

## Project Files

### 1. `config.tf.json`

This file configures the Terraform backend, which specifies where the Terraform state file is stored. In this case, an S3 bucket is used.

```json
{
  "terraform": {
    "backend": {
      "s3": {
        "bucket": "barm-devops-bucket",
        "key": "terraform.tfstate",
        "region": "eu-west-1"
      }
    }
  }
}
```

### 2. `vars.tf`

This file defines the project variables. Key variables include the VPC ID and CIDR block for the subnet.

Example variable definition:

```hcl
variable "subnet_cidr1" {
  description = "The CIDR block for the first subnet"
  default     = "192.168.24.0/24"
}
```

### 3. `main.tf`

The primary Terraform configuration file where resources are defined. The following example creates an AWS subnet with the specified CIDR block:

```hcl
resource "aws_subnet" "barm-terraform-subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr1
  availability_zone = "${var.region}a"    # Availability zone based on region variable

  tags = {
    Name = "barm-terraform-subnet-1"
  }
}
```

### 4. `providers.tf`

This file defines the provider configurations for the project. The AWS provider is configured to use the `eu-west-1` region.

```hcl
provider "aws" {
  region = "eu-west-1"
}
```

### 5. `output.tf`

Defines the output variables of the project. These outputs capture and display useful information about the resources created by Terraform.

## Usage

Follow these steps to use the project:

1. **Clone the Repository**

   Clone the repository to your local machine:

   ```bash
   git clone <repository-url>
   ```

2. **Initialize Terraform**

   Run the following command to download the necessary provider plugins and initialize the backend:

   ```bash
   terraform init
   ```

3. **Apply the Terraform Configuration**

   Apply the configuration to create the subnet and other resources:

   ```bash
   terraform apply
   ```

   Make sure you have the correct AWS credentials set up.

4. **Destroy the Resources**

   To tear down all the infrastructure created by Terraform, run:

   ```bash
   terraform destroy
   ```

## Prerequisites

- AWS account and credentials configured
- Terraform installed on your local machine
