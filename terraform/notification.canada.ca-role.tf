# Define IAM role A with a trust policy that allows it to be assumed by terraform apply role

variable "aws_sso_admin_access_role_arn" {
  description = "ARN for the AWS SSO Administrator Access role"
  type        = string
  sensitive   = true
}

resource "aws_iam_role" "notify_prod_dns_manager" {
  name = "notify_prod_dns_manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::296255494825:role/notification-terraform-apply",
            var.aws_sso_admin_access_role_arn
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Define the IAM policy
resource "aws_iam_policy" "notify_prod_dns_manager_policy" {
  name        = "notify_prod_dns_manager_policy"
  description = "Policy to manage Route53 records for notification.canada.ca hosted zone"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets",
          "route53:GetChange",
          "route53:ListTagsForResource"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:route53:::hostedzone/Z1XG153PQF3VV5"
      },
      {
        Action = [
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:GetHostedZoneCount",
          "route53:ListHostedZonesByName"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "prod_dns_manager_policy_attachment" {
  role       = aws_iam_role.notify_prod_dns_manager.name
  policy_arn = aws_iam_policy.notify_prod_dns_manager_policy.arn
}


# Define IAM role A with a trust policy that allows it to be assumed by terraform plan role

variable "aws_sso_plan_role_arn" {
  description = "ARN for the AWS SSO Plan role"
  type        = string
  sensitive   = true
}

resource "aws_iam_role" "notify_prod_dns_manager_plan" {
  name = "notify_prod_dns_manager_plan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = [
            "arn:aws:iam::296255494825:role/notification-terraform-plan",
            var.aws_sso_plan_role_arn
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "notify_prod_dns_manager_policy_plan" {
  name        = "notify_prod_dns_manager_policy_plan"
  description = "Policy to manage Route53 records for notification.canada.ca hosted zone (Plan role only)"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "route53:ListResourceRecordSets",
          "route53:GetChange",
          "route53:ListTagsForResource"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:route53:::hostedzone/Z1XG153PQF3VV5"
      },
      {
        Action = [
          "route53:GetHostedZone",
          "route53:ListHostedZones",
          "route53:GetHostedZoneCount",
          "route53:ListHostedZonesByName"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prod_dns_manager_policy_attachment_plan" {
  role       = aws_iam_role.notify_prod_dns_manager_plan.name
  policy_arn = aws_iam_policy.notify_prod_dns_manager_policy_plan.arn
}