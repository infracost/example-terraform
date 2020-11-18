terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
    # Install the optional terraform-provider-infracost to enable estimation of usage-based resources such as Lambda
    infracost = { source = "infracost/infracost" }
  }
}
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}
provider "infracost" {}

resource "aws_instance" "web_app" {
  ami           = "ami-674cbc1e"
  instance_type = "a1.medium" # <<<<< Try changing this to a1.xlarge to compare the costs

  root_block_device {
    volume_size = 50
  }

  ebs_block_device {
    device_name = "my_data"
    volume_type = "io1"       # <<<<< Try changing this to gp2 to compare costs
    volume_size = 50
    iops        = 200
  }
}

resource "aws_lambda_function" "hello_world" {
  function_name = "hello_world"
  role          = "arn:aws:lambda:us-east-1:account-id:resource-id"
  handler       = "exports.test"
  runtime       = "nodejs12.x"
  memory_size   = 128         # <<<<< Try changing this to 512 to compare costs
}

# Get cost estimates for Lambda requests and duration
data "infracost_aws_lambda_function" "hello_world" {
  resources = [aws_lambda_function.hello_world.id]
  monthly_requests { value = 100000000 }
  average_request_duration { value = 250 } # <<<<< Try changing this to 100 (milliseconds) to compare costs
}
