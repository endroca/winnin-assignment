data "archive_file" "archive_file_get_api" {
  type = "zip"
  source_dir = var.lambda_get_from_api.path
  output_path = "${var.lambda_get_from_api.path}.zip"
}

resource "aws_iam_role" "iam_for_lambda_ext_api" {
  name = "iam_for_lambda_ext_api"

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

resource "aws_lambda_function" "get_data_from_external_api"{
  role          = aws_iam_role.iam_for_lambda_ext_api.arn
  function_name = var.lambda_get_from_api.function_name
  filename      = "${var.lambda_get_from_api.path}.zip"
  description   = var.lambda_get_from_api.description
  handler       = var.lambda_get_from_api.handler
  runtime       = var.lambda_get_from_api.runtime
  source_code_hash = filebase64sha256("${var.lambda_get_from_api.path}.zip")

  environment {
    variables = {
      rds_endpoint = aws_db_instance.rds.endpoint
      db_username = var.rds.username
      db_password = var.rds.password
      db_name = var.rds.name
    }
  }
}

# Invoke cloudwatch
resource "aws_cloudwatch_event_rule" "every_day" {
    name = "every-day"
    description = "Fires every day"
    schedule_expression = var.lambda_get_from_api.schedule_expression
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