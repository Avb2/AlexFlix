######### Role
#### Trust policy
resource "aws_iam_policy_document" "lambda_cognito_trust" {
    statement {
        principals{ 
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

### Perms Policy 

data "aws_iam_policy_document" "lambda_cognito_perms" {
    statement {
        actions = [
            "cognito:*"
        ]
        resources = [
            var.cognito_arn
        ]
    }
}

resource "aws_iam_role" "lambda_cognito_role" {
    name = "lambda_cognito_role"
    assume_role_policy = data.aws_iam_policy_document.lambda_cognito_trust.json
}

resource "aws_iam_policy" "lambda_cognito_policy" {
    name = "lambda_cognito_policy"
    policy = data.aws_iam_policy_document.lambda_cognito_perms.json
}

# Attach the perms to the role
resource "aws_iam_role_policy_attachment" "lambda_cognito_attach_perms" {
  role       = aws_iam_role.lambda_cognito_role.name
  policy_arn = aws_iam_policy.lambda_cognito_policy.arn
}







### Lambda source file
data "archive_file" "lambda_cognito_file" {
    type = "zip"
    source_file = "${path.module}/lambda/index.py"
    output_path = "${path.module}/lambda/function.zip"
}


### Lambda Function
resource "aws_lambda_function" "lambda_cognito" {
    filename         = data.archive_file.lambda_cognito_file.output_path
    function_name    = "lambda_cognito"
    role             = aws_iam_role.lambda_cognito_role.arn
    handler          = "index.handler"
    source_code_hash = data.archive_file.lambda_cognito_file.output_base64sha256

    runtime = "python3.12"
}