# Terraform Project for AWS Subnet Creation

This project provisions resources on AWS using Terraform. Specifically, it creates a subnet with a CIDR block `192.168.24.0/24` within a specified VPC.

## Project Structure

The repository contains the following files:

```
├── README.md         # Project documentation (this file)
├── config.tf.json    # Terraform configuration for backend
├── data.tf           # Data sources
├── main.tf           # Main configuration for resource creation
├── output.tf         # Output values
├── providers.tf      # Providers configuration
└── vars.tf           # Variable definitions
```

### 1. `config.tf.json`
This file contains the backend configuration for Terraform, which defines where the state file will be stored. In this case, the backend is configured to use an S3 bucket.

```
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
This file defines the variables used throughout the project. It contains variables like the VPC ID and CIDR block for the subnet.

Example variable definition:
```
variable "subnet_cidr1" {
  description = "The CIDR block for the first subnet"
  default     = "192.168.24.0/24"
}
```

### 3. `main.tf`
The main Terraform configuration file, which defines the resources to be created. Below is an example of creating an AWS subnet with the appropriate CIDR block:

```
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
This file defines the provider configuration. For this project, we use the AWS provider:

```
provider "aws" {
  region = "eu-west-1"
}
```

### 5. `output.tf`
This file defines the outputs of the project, allowing us to capture and display information about the created resources.

## How to Use

1. **Clone the repository**:
   ```
   git clone <repository-url>
   ```

2. **Initialize Terraform**:
   ```
   terraform init
   ```

   This will download the necessary provider plugins and initialize the backend.

3. **Apply the configuration**:
   ```
   terraform apply
   ```

   This will create the subnet and other resources as defined in `main.tf`. Ensure you have the correct AWS credentials configured.

4. **Destroy resources**:
   ```
   terraform destroy
   ```

   This command will tear down all the infrastructure created by Terraform.

## Requirements

- Terraform >= 0.12
- AWS account and credentials
- Configured S3 bucket for state storage

## Notes

- Ensure you have the correct IAM permissions to create the necessary resources in AWS.
- Customize the region and CIDR block by modifying the variables in `vars.tf`.
