############################################################################################
# Copyright 2019 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
############################################################################################

// Source Python script for the Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/autoshutoff.zip"
}

//  Create the IAM role and attached policies
resource "aws_iam_role" "autoshutoff_role" {
  name        = "${var.lambda_function_name}Role"
  description = "Allow Lambda functions to describe and stop EC2 instances in all regions."

  tags = merge(
    {
      "Name" = format("%s-Role", var.lambda_function_name)
    },
    var.tags,
  )

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "autoshutoff_policy" {
  name = "${var.lambda_function_name}Execute"
  role = aws_iam_role.autoshutoff_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeRegions",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:StopInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "logging_policy" {
  name = "${var.lambda_function_name}Logging"
  role = aws_iam_role.autoshutoff_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF

}

// Define the Lambda function
resource "aws_lambda_function" "autoshutoff" {
  function_name = var.lambda_function_name
  description = "A Lambda function to stop running EC2 instances nightly."
  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role = aws_iam_role.autoshutoff_role.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.7"
  timeout = 30

  environment {
    variables = {
      SHUTOFF_TAG_NAME = var.shutoff_tag_name
      SHUTOFF_TAG_VALUE = var.shutoff_tag_value
    }
  }
}

// Define CloudWatch schedule trigger and target
resource "aws_cloudwatch_event_rule" "autoshutoff_rule" {
  name = "${var.lambda_function_name}-Rule"
  description = "This rule will be used to trigger the ${var.lambda_function_name} function."
  schedule_expression = var.shutoff_time

  tags = merge(
    {
      "Name" = format("%s-Rule", var.lambda_function_name)
    }, var.tags,
  )
}

resource "aws_cloudwatch_event_target" "autoshutoff_target" {
  rule = aws_cloudwatch_event_rule.autoshutoff_rule.name
  target_id = aws_lambda_function.autoshutoff.function_name
  arn = aws_lambda_function.autoshutoff.arn
}

// Allow CloudWatch to execute the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch_to_call_autoshutoff" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.autoshutoff.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.autoshutoff_rule.arn
}

// Create the CloudWatch log group
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

