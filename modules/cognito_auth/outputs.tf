output "cognito_arn" {
    description = "Cognito user pool ARN"
    value = aws_cognito_user_pool.user_pool.arn
}


output "cognito_id" {
    description = "Cognito user pool ARN"
    value = aws_cognito_user_pool.user_pool.id
}

