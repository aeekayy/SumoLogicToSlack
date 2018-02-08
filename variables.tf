variable "aws_access_key_id" {}

variable "aws_secret_access_key" {}

variable "aws_region" {}

variable "aws_account_id" {
	description = "The account id for the AWS account."
	default = "478685488679"
}

variable "snsName" {
	type = "string"
	default = "codeship_deployments"
}

variable "snsArn" {
	type = "string"
	default = "arn:aws:sns:us-west-2:478685488679:codeship_deployments"
}

variable "method" {
  description = "The HTTP method"
  default     = "POST"
}

variable "slackChannel" {
	type = "string"
	default = "#aws"
}

variable "kmsEncryptedHookUrl" {
	type = "string"
	default = ""
}
