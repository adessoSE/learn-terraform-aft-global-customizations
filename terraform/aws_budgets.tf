data "aws_organizations_organization" "org" {}

data "aws_organizations_accounts" "accounts" {}

resource "aws_budgets_budget" "per_account_budget" {
  for_each = { for acct in data.aws_organizations_accounts.accounts.accounts : acct.id => acct }

  name         = "budget-${each.key}" # Her hesap için farklı isim
  budget_type  = "COST"
  limit_amount = "1000"
  limit_unit   = "USD" # Budget is set in USD
  time_unit    = "MONTHLY"

  cost_filters = {
    LinkedAccount = [each.key]  # Each account gets its own budget
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [each.value.email] # Account'ın kendi emaili
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
  }
}

resource "aws_sns_topic" "budget_alerts" {
  name = "budget-alerts"
}

resource "aws_sns_topic_subscription" "root_subscription" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = "itmc-aws-root@adesso-service.com" # Root hesap için bildirim
}

resource "aws_sns_topic_subscription" "admin_subscription" {
  topic_arn = aws_sns_topic.budget_alerts.arn
  protocol  = "email"
  endpoint  = "bekir.kocabas@adesso.de" # Admin için bildirim
}

