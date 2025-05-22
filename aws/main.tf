provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

resource "aws_instance" "my_web_app" {
  ami = "ami-005e54dee72cc1d00"

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

resource "aws_instance" "new_web_app" {
  ami = "ami-005e54dee72cc1d00"

  instance_type = "m3.2xlarge"

  tags = {
    Environment = "prod"
    Service     = "web-app"
  }

  volume_tags = {
    Environment = "production"
  }

  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  ebs_block_device {
    volume_type = "gp3"
    iops        = "20000"
  }
}

resource "aws_db_instance" "mydb" {
  allocated_storage       = 20
  storage_type            = "gp3"
  engine                  = "postgres"
  engine_version          = "11.13"
  instance_class          = "db.t4g.medium"
  name                    = "mydb"
  username                = "admin"
  password                = "mypassword"
  parameter_group_name    = "default.postgres11"
  multi_az                = false
  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = {
    Environment = "production"
    Service     = "web-app"
  }
}



