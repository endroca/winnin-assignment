data "archive_file" "archive_file_first_endpoint" {
  type = "zip"
  source_dir = var.lambda_first_endpoint.path
  output_path = "${var.lambda_first_endpoint.path}.zip"
}

resource "aws_iam_role" "iam_for_lambda_first_endpoint" {
  name = "iam_for_lambda_first_endpoint"

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

resource "aws_lambda_function" "first_endpoint_api"{
  role          = aws_iam_role.iam_for_lambda_first_endpoint.arn
  function_name = var.lambda_first_endpoint.function_name
  filename      = "${var.lambda_first_endpoint.path}.zip"
  description   = var.lambda_first_endpoint.description
  handler       = var.lambda_first_endpoint.handler
  runtime       = var.lambda_first_endpoint.runtime
  source_code_hash = base64sha256("${var.lambda_first_endpoint.path}.zip")

  environment {
    variables = {
      rds_endpoint = aws_db_instance.rds.endpoint
      db_username = var.rds.username
      db_password = var.rds.password
      db_name = var.rds.name
    }
  }
}

resource "aws_api_gateway_rest_api" "firstEndPoint" {
  name        = "firstEndPoint"
  description = "Serverless Application FirstEndPoint"
}

resource "aws_api_gateway_resource" "proxy" {
   rest_api_id = aws_api_gateway_rest_api.firstEndPoint.id
   parent_id   = aws_api_gateway_rest_api.firstEndPoint.root_resource_id
   path_part   = "resource"
}

resource "aws_api_gateway_method" "proxy" {
   rest_api_id   = aws_api_gateway_rest_api.firstEndPoint.id
   resource_id   = aws_api_gateway_resource.proxy.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
   rest_api_id = aws_api_gateway_rest_api.firstEndPoint.id
   resource_id = aws_api_gateway_method.proxy.resource_id
   http_method = aws_api_gateway_method.proxy.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.first_endpoint_api.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
   rest_api_id   = aws_api_gateway_rest_api.firstEndPoint.id
   resource_id   = aws_api_gateway_rest_api.firstEndPoint.root_resource_id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
   rest_api_id = aws_api_gateway_rest_api.firstEndPoint.id
   resource_id = aws_api_gateway_method.proxy_root.resource_id
   http_method = aws_api_gateway_method.proxy_root.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.first_endpoint_api.invoke_arn
}

resource "aws_api_gateway_deployment" "firstEndPointDeploy" {
   depends_on = [
     aws_api_gateway_integration.lambda,
     aws_api_gateway_integration.lambda_root,
   ]

   rest_api_id = aws_api_gateway_rest_api.firstEndPoint.id
   stage_name  = "firstEndPoint"
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.first_endpoint_api.function_name
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.firstEndPoint.execution_arn}/*/*"
}