
resource "aws_cloudwatch_event_rule" "ec2_terminated" {
  name        = "ec2-terminated"
  description = "EC2 terminated notification"

  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    "detail" : {
      "state" : ["terminated"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ec2_terminated" {
  rule      = aws_cloudwatch_event_rule.ec2_terminated.name
  target_id = "ec2-terminated"
  arn       = aws_sns_topic.main.arn
  input_transformer {
    input_paths = {
      "id" : "$.id",
      "account" : "$.account",
      "time" : "$.time",
      "region" : "$.region"
      "instance-id" : "$.detail.instance-id"
    }
    input_template = <<EOF
{
    "version": "1.0",
    "source": "custom",
    "id": "<id>",
    "content": {
        "title": "@here EC2がTerminateされました :shocked-cat:",
        "description": "しかし勉強会のデモなので問題ありません :happy-cat:",
        "nextSteps": [
            "id: *<id>*",
            "account: *<account>*",
            "time: *<time>* :wet-cat:＜UTCなので注意",
            "region: *<region>*",
            "instance-id: *<instance-id>* :screaming-cat:"
        ],
        "keywords": ["EC2", "Terminate", "勉強会"]
    },
    "metadata": {
        "summary": "aws chatbot demonstration"
    }
}
EOF
  }
}

resource "aws_sns_topic" "main" {
  name = "sample-topic"
}

resource "aws_sns_topic_policy" "main" {
  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "main" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.main.arn]
  }
}

resource "awscc_chatbot_slack_channel_configuration" "example_slack" {
  configuration_name = "example-slack-channel-config"
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_channel_id   = ""  # Slack channel ID（Cから始まるID）
  slack_workspace_id = ""  # Slack workspace ID（Tから始まるID）
  sns_topic_arns     = [aws_sns_topic_policy.main.arn]
}

resource "aws_iam_role" "chatbot" {
  name               = "ChatbotRoleTest"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "chatbot.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonQFullAccess"
  ]
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot.arn
}

resource "aws_iam_policy" "chatbot" {
  name = "lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:invokeAsync",
          "lambda:invokeFunction",
          "ce:GetCostAndUsage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
