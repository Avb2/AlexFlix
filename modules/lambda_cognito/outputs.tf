output "lambda_arn" {
    value = aws_lambda_function.lambda_cognito.arn
}


output "lambda_id" {
    value = aws_lambda_function.lambda_cognito.id
}