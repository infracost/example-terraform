provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

resource "aws_instance" "my_web_app" {
  ami           = "ami-005e54dee72cc1d00"

  instance_type = "m3.xlarge" # <<<<<<<<<< Try changing this to m5.xlarge to compare the costs

  tags = {
    Environment = "production"
    Service     = "web-app"
  }

  root_block_device {
    volume_size = 1000 # <<<<<<<<<< Try adding volume_type="gp3" to compare costs
  }
}

resource "aws_lambda_function" "my_hello_world" {
  runtime       = "nodejs12.x"
  handler       = "exports.test"
  image_uri     = "test"
  function_name = "test"
  role          = "arn:aws:ec2:us-east-1:123123123123:instance/i-1231231231"

  memory_size = 512
  tags = {
    Environment = "Prod"
  }
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
