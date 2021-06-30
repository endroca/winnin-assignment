terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

# Invoke lambda first apply
module "execute" {
  source              ="connect-group/lambda-exec/aws"
  name                = "lambda_execution"
  lambda_function_arn = aws_lambda_function.get_data_from_external_api.arn

  lambda_inputs = {
    run_on_every_apply = timestamp()
  }

  lambda_outputs = []
}