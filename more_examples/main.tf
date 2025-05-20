provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name = "my_app_logs"
}

resource "aws_s3_bucket" "screenshots_dev" {
  bucket = "my_screenshots_bucket_dev"
}

resource "aws_s3_bucket" "screenshots_stage" {
  bucket = "my_screenshots_bucket_stage"
}

resource "aws_s3_bucket" "screenshots_qa" {
  bucket = "my_screenshots_bucket_qa"
}

resource "aws_s3_bucket" "screenshots_prod" {
  bucket = "my_screenshots_bucket_prod"
}

resource "aws_db_instance" "my_db" {
  identifier         = "mysql57-extended"
  engine             = "mysql"
  engine_version     = "5.7.44"
  instance_class     = "db.t3.medium"
  allocated_storage  = 20
  storage_type       = "gp2"
  username           = "admin"
  password           = "yourpassword"
  db_name            = "exampledb"
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "my-eks-extended"
  cluster_version = "1.24"
  subnet_ids      = ["subnet-abc123", "subnet-def456"]
  vpc_id          = "vpc-123456"

  node_groups = {
    default = {
      desired_capacity = 100
      max_capacity     = 300
      min_capacity     = 50

      instance_types = ["c5.2xlarge"]
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_log_analytics_workspace" "azure_logs" {
  name                = "example-logs"
  location            = "East US" 
  resource_group_name = "example-rg"
  sku                 = "PerGB2018"
}
