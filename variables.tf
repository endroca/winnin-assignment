variable "region" {
  default = "us-east-2"
}

variable "lambda_get_from_api" {
  default = {
    runtime = "nodejs14.x"
    function_name = "get_data_from_external_api"
    path = "src/lambdaGetFromAPI"
    handler = "request.handler"
    description = "get data from an external API"
    schedule_expression = "rate(1 day)"
  }
}

variable "lambda_first_endpoint" {
  default = {
    runtime = "nodejs14.x"
    function_name = "first_endpoint"
    path = "src/lambdaFirstEndPoint"
    handler = "request.handler"
    description = "get data from rds"
  }
}

variable "lambda_second_endpoint" {
  default = {
    runtime = "nodejs14.x"
    function_name = "second_endpoint"
    path = "src/lambdaSecondEndPoint"
    handler = "request.handler"
    description = "get data from rds"
  }
}

variable "rds" {
  default = {
    allocated_storage    = 10
    engine               = "mysql"
    engine_version       = "8.0"
    instance_class       = "db.t3.micro"
    name                 = "db"
    username             = "root"
    password             = "123456789"
    parameter_group_name = "default.mysql8.0"
  }
}