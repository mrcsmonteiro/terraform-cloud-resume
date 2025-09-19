resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # The thumbprint for GitHub's OIDC provider.
  # This may change periodically. You can get the latest from AWS docs.
  thumbprint_list = [
    "6938fd485d2ba784364c3963b6522ff3074465b8"
  ]
}

resource "aws_iam_role" "github_actions_resume" {
  name = "github-actions-resume"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc_provider.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" : "repo:mrcsmonteiro/terraform-cloud-resume:ref:refs/heads/prod"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_resume_policy" {
  name = "github-actions-resume-policy"
  role = aws_iam_role.github_actions_resume.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "acm:*",
          "cloudfront:*",
          "route53:*",
          "lambda:*",
          "apigateway:*",
          "s3:*",
          "dynamodb:*",
          "iam:*",
          "glue:*",
          "athena:*"
        ]
        Resource = "*"
      }
    ]
  })
}