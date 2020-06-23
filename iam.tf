data "aws_iam_policy_document" "service_assume_role" {
  statement {
    sid = "AllowECSToAssumeRoles"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "service" {
  name = format("%s", var.service_name)
  assume_role_policy = data.aws_iam_policy_document.service_assume_role.json
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_service_policy" {
  role = aws_iam_role.service.name
  policy_arn = var.service_role_policy_arn
}