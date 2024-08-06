
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

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.s3_created.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.topic.arn
  input_transformer {
    input_paths = {
      "id" : "$.id",
      "account" : "$.account",
      "Region" : "$.region",
    }
    input_template = <<EOF
{
    "version": "1.0",
    "source": "custom",
    "id": "<id>",
    "content": {
        "title": "S3 Notification",
        "description": "S3 Notification dayo dayo",
        "nextSteps": [
            "hello",
            "world:shocked-cat:"
        ]
    }
}
EOF
  }
}

resource "aws_sns_topic" "topic" {
  name       = "topic"
  fifo_topic = false
}

resource "aws_sns_topic_policy" "policy" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.topic.arn]
  }
}

resource "awscc_chatbot_slack_channel_configuration" "example" {
  configuration_name = "example-slack-channel-config"
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_channel_id   = "your-slack-channel-id"   # Replace with your Slack channel ID
  slack_workspace_id = "your-slack-workspace-id" # Replace with your Slack workspace ID
  sns_topic_arns     = [aws_sns_topic_policy.policy.arn]
}

resource "aws_iam_role" "chatbot" {
  name                = "ChatbotRoleTest"
  assume_role_policy  = <<EOF
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
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess", "arn:aws:iam::aws:policy/AmazonQFullAccess"]
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_iam_policy" "lambda" {
  name = "lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:invokeAsync",
          "lambda:invokeFunction",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
