terraform {
  # use_lockfile requiere Terraform >= 1.10
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket  = "ssachez.itm-lab-ps-1"
    key     = "01-k3s-lab/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "PPatrones"
    # Bloqueo nativo en S3 (archivo .tflock junto al estado): evita dos apply a la vez
    use_lockfile = true
  }

  required_providers {
    aws = { source = "hashicorp/aws"
    version = "~> 6.0" }
    random = { source = "hashicorp/random"
    version = "~> 3.6" }
  }
}

# Configure and downloading plugins for AWS
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}