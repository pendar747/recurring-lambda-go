provider "aws" {
  region = "us-west-2"
}

// Create a role for the Lambda function
resource "aws_lambda_function" "my_recurring_lambda" {
  filename         = "../bin/bootstrap.zip"
  function_name    = "my_recurring_lambda"
  handler          = "lambda_function_payload"
  source_code_hash = filebase64sha256("../bin/bootstrap.zip")
  runtime          = "provided.al2" // golang
  role             = aws_iam_role.my_recurring_lambda_iam_role.arn
}

resource "aws_iam_role" "my_recurring_lambda_iam_role" {
  name = "my_recurring_lambda_iam_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
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

// Create a rule that will trigger the Lambda function every 2 minutes
resource "aws_cloudwatch_event_rule" "my_recurring_lambda_schedule" {
  name                = "run_every_2_minutes"
  schedule_expression = "cron(0/2 * * * ? *)"
}

// Create a target for the rule that will invoke the Lambda function
resource "aws_cloudwatch_event_target" "my_recurring_lambda_target" {
  rule      = aws_cloudwatch_event_rule.my_recurring_lambda_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.my_recurring_lambda.arn
}

// Allow CloudWatch to invoke the Lambda function
resource "aws_lambda_permission" "my_recurring_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_recurring_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.my_recurring_lambda_schedule.arn
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

// iam role policy attachment to allow Lambda to write logs
resource "aws_iam_role_policy_attachment" "my_recurring_lambda_iam_role" {
  role       = aws_iam_role.my_recurring_lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "my_recurring_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.my_recurring_lambda.function_name}"
  retention_in_days = 14
}

