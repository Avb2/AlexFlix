

###### Auth
module "cognito_auth" {
    source = "./modules/cognito_auth"
}

module "lambda_cognito" {
    source = "./modules/cognito_auth"
}
