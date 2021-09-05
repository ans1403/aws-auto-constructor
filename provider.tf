terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.57.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0"
    }
  }

  # will be configurated by Makefile
  backend "s3" {}
}

# will be configurated by Makefile
provider "aws" {}
