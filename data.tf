data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["DevOps-Workshop"]
  }
}

data "aws_nat_gateway" "selected" {
  filter {
    name   = "tag:Name"
    values = ["devops-workshop-nat"]
  }
  state = "available"
}
data "aws_iam_user" "current_users" {
  for_each  = toset(var.iam_user_names)
  user_name = each.value
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowSpecificUserAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [for user in data.aws_iam_user.current_users : user.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::barm-devops-bucket",
      "arn:aws:s3:::barm-devops-bucket/*"
    ]
  }
}
