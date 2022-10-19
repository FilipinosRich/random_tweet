terraform {
  required_version = "~> 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-filipinosrich"
    key            = "tfstate/terraform.tfstate"
    dynamodb_table = "terraform-state-lock-filipinosrich"
    region         = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Project             = "Random_Tweet"
      Terraform           = true
      Staging-environment = "${terraform.workspace}"
    }
  }
}
