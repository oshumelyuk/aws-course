data "aws_iam_policy_document" "s3_accesspolicy_document" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*"
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "dynamodb_accesspolicy_document" {
  statement {
    actions = [
      "dynamodb:ListTables",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:PutItem"
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "sqs_accesspolicy_document" {
  statement {
    actions = [
      "sqs:*"
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "sns_accesspolicy_document" {
  statement {
    actions = [
      "sns:*"
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "rds_accesspolicy_document" {
  statement {
    actions = [
      "rds:CreateDBInstance",
      "rds:ModifyDBInstance"
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "ec2tags_accesspolicy_document" {
  statement {
    actions = [
      "ec2:DescribeTags"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ac_s3_accesspolicy" {
  name   = "ac_s3_accesspolicy"
  policy = data.aws_iam_policy_document.s3_accesspolicy_document.json
}

resource "aws_iam_policy" "ac_dynamodb_accesspolicy" {
  name   = "ac_dynamodb_accesspolicy"
  policy = data.aws_iam_policy_document.dynamodb_accesspolicy_document.json
}

resource "aws_iam_policy" "ac_sqs_accesspolicy" {
  name   = "ac_sqs_accesspolicy"
  policy = data.aws_iam_policy_document.sqs_accesspolicy_document.json
}

resource "aws_iam_policy" "ac_sns_accesspolicy" {
  name   = "ac_sns_accesspolicy"
  policy = data.aws_iam_policy_document.sns_accesspolicy_document.json
}

resource "aws_iam_policy" "ac_rds_accesspolicy" {
  name   = "ac_rds_accesspolicy"
  policy = data.aws_iam_policy_document.rds_accesspolicy_document.json
}

resource "aws_iam_policy" "ac_ec2tags_accesspolicy" {
  name   = "ac_ec2tags_accesspolicy"
  policy = data.aws_iam_policy_document.ec2tags_accesspolicy_document.json
}