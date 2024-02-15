# # Creating a S3 Bucket
# resource "aws_s3_bucket" "my_bucket" {
#   bucket = "my-cloud-resume-challenge-aws"
# }

# # Enabling the Static Site for S3 bucket

# resource "aws_s3_bucket_website_configuration" "static_site" {
#   bucket = aws_s3_bucket.my_bucket.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }
# }

# Creates Dynamodb Table
resource "aws_dynamodb_table" "visitors" {
    name = "visitors"
    billing_mode = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    hash_key = "id"

    attribute {
        name = "id"
        type = "S"
    }
}

# Lambda Func IAM Role

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Dyanamodb Full access Role
data "aws_iam_role" "dynamodb_full_access_role" {
  name = "lambda-dynamo-db-full-access"
}

# Creates a lambda function
resource "aws_lambda_function" "my_function" {
    filename = data.archive_file.zip.output_path
    source_code_hash = data.archive_file.zip.output_base64sha256
    function_name = "my_function"
    role = data.aws_iam_role.dynamodb_full_access_role.arn
    handler = "my_function.lambda_handler"
    runtime = "python3.9"
}

# Enabling the function url

resource "aws_lambda_function_url" "url" {
    function_name = aws_lambda_function.my_function.function_name
    authorization_type = "NONE"
    cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

# Uploading the function files 

data "archive_file" "zip" {
  type        = "zip"
  source_dir = "${path.module}/lambda_function/"
  output_path = "${path.module}/lambda_function_payload.zip"
}

