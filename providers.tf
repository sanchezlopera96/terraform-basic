terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket  = "ssachez.itm-lab-ps-1"
    key     = "01-k3s-lab/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "PPatrones"
  }

  required_providers {
    aws = { source = "hashicorp/aws"
    version = "~> 6.0" }
  }
}

# Configure and downloading plugins for AWS
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}