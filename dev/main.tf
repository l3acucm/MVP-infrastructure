terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "terraform-backend-zuber"
    key    = "mvp.tfstate"
    region = "us-east-1"
    dynamodb_endpoint = "dynamodb.us-east-1.amazonaws.com"
    dynamodb_table = "mvp-infrastructure-state-lock"
  }
}

provider "aws" {
  access_key = var.aws_keys["terraform"].access
  secret_key = var.aws_keys["terraform"].secret
  region = var.aws_region
}

provider "aws" {
  access_key = var.aws_keys["terraform"].access
  secret_key = var.aws_keys["terraform"].secret
  region = "us-east-1"
  alias = "for_certificates"
}

provider "github" {
  token = var.github_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
