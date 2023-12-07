variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_db_instance" "postgresql_instance" {
  identifier        = "sampledb"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = "12"
  instance_class    = "db.t2.micro"
  username             = "postgres"
  password             = "postgres"
  parameter_group_name = "default.postgres12"
}

resource "aws_lambda_function" "alert_message_lambda" {
  filename      = "../function.zip"
  function_name = "alert_email"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index"
  runtime       = "nodejs18.x"
}

resource "aws_iam_role" "lambda_exec" {
  # IAM role for Lambda execution
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

# cloudwatch logs
resource "aws_cloudwatch_log_group" "postgresql_log_group" {
  name              = "/aws/rds/instance/${aws_db_instance.postgresql_instance.identifier}/postgresql"
  retention_in_days = 7
}

# subscriptionfilter
resource "aws_cloudwatch_log_subscription_filter" "lambda_subscription_filter" {
  name            = "query"
  log_group_name  = aws_cloudwatch_log_group.postgresql_log_group.name
  filter_pattern  = "LOG:  AUDIT: OBJECT"
  destination_arn = aws_lambda_function.alert_message_lambda.arn
}


# cloudWatch logs => lambda
resource "aws_lambda_permission" "allow_cloudwatch_logs" {
  statement_id  = "AllowExecutionFromCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_message_lambda.function_name
  principal     = "logs.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.postgresql_log_group.arn
}


# SNS topic
resource "aws_sns_topic" "email_topic" {
  name = "your_sns_topic_name"
}

# SNS subscription
resource "aws_sns_topic_subscription" "example_subscription" {
  topic_arn = aws_sns_topic.email_topic.arn
  protocol  = "email"
  endpoint  = "your_email@example.com"
}
