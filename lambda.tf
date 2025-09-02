# IAM Role and Policies for Lambda Functions
# This data source creates a policy document that allows the Lambda service
# to assume the role.
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# This resource creates the IAM role that both Lambda functions will use.
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda-visitor-counter-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Policy for logging to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy for DynamoDB read permissions (for the GET Lambda)
resource "aws_iam_role_policy" "lambda_dynamodb_read_policy" {
  name = "LambdaDynamoDBReadPolicy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["dynamodb:GetItem"],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.visitor_counts.arn
      }
    ]
  })
}

# Policy for DynamoDB write/update permissions (for the POST Lambda)
resource "aws_iam_role_policy" "lambda_dynamodb_write_policy" {
  name = "LambdaDynamoDBWritePolicy"
  role = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["dynamodb:UpdateItem"],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.visitor_counts.arn
      }
    ]
  })
}

# Lambda Functions

# Data source to package the Python code into a .zip file locally.
data "archive_file" "get_visitor_count_zip" {
  type        = "zip"
  source_file = "lambda_get_visitor_count.py"
  output_path = "lambda_get_visitor_count.zip"
}

data "archive_file" "increment_visitor_count_zip" {
  type        = "zip"
  source_file = "lambda_increment_visitor_count.py"
  output_path = "lambda_increment_visitor_count.zip"
}

# Lambda function for GET requests
resource "aws_lambda_function" "get_visitor_count" {
  function_name    = "getVisitorCount"
  filename         = data.archive_file.get_visitor_count_zip.output_path
  handler          = "lambda_get_visitor_count.lambda_handler"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_execution_role.arn
  source_code_hash = data.archive_file.get_visitor_count_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.visitor_counts.name
    }
  }
}

# Lambda function for POST requests
resource "aws_lambda_function" "increment_visitor_count" {
  function_name    = "incrementVisitorCount"
  filename         = data.archive_file.increment_visitor_count_zip.output_path
  handler          = "lambda_increment_visitor_count.lambda_handler"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_execution_role.arn
  source_code_hash = data.archive_file.increment_visitor_count_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.visitor_counts.name
    }
  }
}