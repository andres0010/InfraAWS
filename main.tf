terraform {

  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "InfraAWS" {
  source = "./AWS_Resources"
}