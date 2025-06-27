locals {
    pool_name = "user-pool"

    mfa_config = "ON"
    sms_msg = "Your code for AlexFlix is {####}"


    # Role config
    role_name = "access_sns_role"
    perm_name = "sns_perms"
}



#### ROLE


# Allows Cognito to assume this role
data "aws_iam_policy_document" "sns_allow_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }
  }
}

# Allows role to use SNS
data "aws_iam_policy_document" "sns_perms_document_policy" {
  statement {
    actions = [
      "lambda:*"
      ]
    resources = [
        var.cognito_lambda_arn
    ]
  }
}





# Creates the role
resource "aws_iam_role" "sns_allow_role" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.sns_allow_trust_policy.json
}



# Attach the document policy to the perms policy
resource "aws_iam_policy" "sns_perms" {
  name        = local.perm_name
  description = "Allows access to SNS from Cognito service"
  policy      = data.aws_iam_policy_document.sns_perms_document_policy.json
}

# Attach the perms to the role
resource "aws_iam_role_policy_attachment" "sns_attach_perms" {
  role       = aws_iam_role.sns_allow_role.name
  policy_arn = aws_iam_policy.sns_perms.arn
}





### USER POOL

resource "aws_cognito_user_pool" "user_pool" {
  name                      = local.pool_name
  mfa_configuration         = local.mfa_config




  software_token_mfa_configuration {
    enabled = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }


  password_policy {
    minimum_length = 6
    require_lowercase = true
    require_numbers = true
    require_symbols = true
    require_uppercase = true
  }



  custom_email_sender {
    lambda_arn = module.lambda_cognito.lambda_arn
    lambda_version = 1
  }
  
}