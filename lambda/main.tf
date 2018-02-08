data "aws_iam_policy_document" "lambdaSns" {
	statement {
		effect = "Allow"
		
		actions = [
			"logs:CreateLogGroup",
			"logs:CreateLogStream",
			"logs:PutLogEvents",
		]

		resources = [
			"*",
		]
	}

	statement {
		effect = "Allow"

		actions = [
			"lambda:Invoke*",
			"lambda:List*",
			"lambda:Get*"
		]

		resources = [
			"*",
		]
	}

	statement {
		effect = "Allow"

		actions = [
			"dynamodb:*"
		]

		resources = [
			"arn:aws:dynamodb:us-west-2:478685488679:table/cogility_autoscaling_groups"
		]
	}

	statement {
		effect = "Allow"

		actions = [
			"autoscaling:*"
		]

		resources = [
			"*",
		]
	}
}

resource "aws_iam_policy" "iam_for_slack_policy" {
	name = "iam_for_slack_policy"
	path = "/service-role/"
	policy = "${data.aws_iam_policy_document.lambdaSns.json}"
}

data "aws_iam_policy_document" "slack-lambda-assume-role-policy" {
        statement {
                actions = ["sts:AssumeRole"]

                principals {
                        type = "Service"
                        identifiers = ["lambda.amazonaws.com"]
                }
        }
}

resource "aws_iam_role" "iam_for_slack_lambda" {
	name = "iam_for_slack_lambda"
	assume_role_policy = "${data.aws_iam_policy_document.slack-lambda-assume-role-policy.json}"
	path = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "iam-slack-lambda-attach" {
	role	= "${aws_iam_role.iam_for_slack_lambda.name}"
	policy_arn	= "${aws_iam_policy.iam_for_slack_policy.arn}"
}

resource "archive_file" "slack_lambda_archive" {
	source_file	= "python/slack.py"
	output_path	= "/tmp/slack_lambda_archive.zip"
	type		= "zip"
}

resource "aws_lambda_function" "lambda_slack" {
        function_name   = "lambda_slack"
        role            = "${aws_iam_role.iam_for_slack_lambda.arn}"
        handler         = "slack.lambda_handler"
        runtime         = "python2.7"
        description     = "Receive a Slack message and do something with it."
        timeout         = "90"
        kms_key_arn     = "${aws_kms_key.aws_slack_key.arn}"
	filename	= "/tmp/slack_lambda_archive.zip"
	source_code_hash = "${archive_file.slack_lambda_archive.output_base64sha256}"
        environment {
                variables = {
                        SnsArn = "${var.snsArn}"
                        slackChannel = "${var.slackChannel}"
                        kmsEncryptedHookUrl = "${var.kmsEncryptedHookUrl}"
			slackToken = "whJPiHp73aKCQMSObIyfytHk"
                }
        }
	tags = {
		Name	= "lambda_slack"
		Environment = "Production"
		Purpose	= "Slack ChatOps"
	}
}
