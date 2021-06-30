data "archive_file" "archive_file_second_endpoint" {
  type = "zip"
  source_dir = var.lambda_second_endpoint.path
  output_path = "${var.lambda_second_endpoint.path}.zip"
}

resource "aws_iam_role" "iam_for_lambda_second_endpoint" {
  name = "iam_for_lambda_second_endpoint"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_function" "second_endpoint_api"{
  role          = aws_iam_role.iam_for_lambda_second_endpoint.arn
  function_name = var.lambda_second_endpoint.function_name
  filename      = "${var.lambda_second_endpoint.path}.zip"
  description   = var.lambda_second_endpoint.description
  handler       = var.lambda_second_endpoint.handler
  runtime       = var.lambda_second_endpoint.runtime
  source_code_hash = filebase64sha256("${var.lambda_second_endpoint.path}.zip")

  environment {
    variables = {
      rds_endpoint = aws_db_instance.rds.endpoint
      db_username = var.rds.username
      db_password = var.rds.password
      db_name = var.rds.name
    }
  }
}

resource "aws_api_gateway_rest_api" "secondEndPoint" {
  name        = "secondEndPoint"
  description = "Serverless Application SecondEndPoint"
}

resource "aws_api_gateway_resource" "proxy2" {
   rest_api_id = aws_api_gateway_rest_api.secondEndPoint.id
   parent_id   = aws_api_gateway_rest_api.secondEndPoint.root_resource_id
   path_part   = "resource"
}

resource "aws_api_gateway_method" "proxy2" {
   rest_api_id   = aws_api_gateway_rest_api.secondEndPoint.id
   resource_id   = aws_api_gateway_resource.proxy2.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda2" {
   rest_api_id = aws_api_gateway_rest_api.secondEndPoint.id
   resource_id = aws_api_gateway_method.proxy2.resource_id
   http_method = aws_api_gateway_method.proxy2.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.second_endpoint_api.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root2" {
   rest_api_id   = aws_api_gateway_rest_api.secondEndPoint.id
   resource_id   = aws_api_gateway_rest_api.secondEndPoint.root_resource_id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root2" {
   rest_api_id = aws_api_gateway_rest_api.secondEndPoint.id
   resource_id = aws_api_gateway_method.proxy_root2.resource_id
   http_method = aws_api_gateway_method.proxy_root2.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.second_endpoint_api.invoke_arn
}

resource "aws_api_gateway_deployment" "secondEndPointDeploy" {
   depends_on = [
     aws_api_gateway_integration.lambda2,
     aws_api_gateway_integration.lambda_root2,
   ]

   rest_api_id = aws_api_gateway_rest_api.secondEndPoint.id
   stage_name  = "secondEndPoint"
}

resource "aws_lambda_permission" "apigw2" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.second_endpoint_api.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.secondEndPoint.execution_arn}/*/*"
}