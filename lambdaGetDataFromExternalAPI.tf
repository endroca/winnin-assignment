data "archive_file" "lambda" {
  type = "zip"
  source_dir = var.lambda_get_from_api.path
  output_path = "get_data_from_external_api.zip"
}

resource "aws_lambda_function" "get_data_from_external_api"{
  role          = aws_iam_role.iam_for_lambda.arn
  function_name = var.lambda_get_from_api.function_name
  filename      = "get_data_from_external_api.zip"
  description   = var.lambda_get_from_api.description
  handler       = "get_data_from_external_api.handle"
  runtime       = var.lambda_get_from_api.runtime
  source_code_hash = base64sha256("get_data_from_external_api.zip")

  environment {
    variables = {
      rds_endpoint = aws_db_instance.rds.endpoint
      db_username = var.rds.username
      db_password = var.rds.password
      db_name = var.rds.name
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_day" {
    name = "every-day"
    description = "Fires every day"
    schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "cloudwatch_event_target_every_day" {
    rule = aws_cloudwatch_event_rule.every_day.name
    arn = aws_lambda_function.get_data_from_external_api.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_cloudwatch_event" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.get_data_from_external_api.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_day.arn
}


resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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