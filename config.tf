provider "aws" {
  region                  = "${local.aws_region}"
  shared_credentials_file = "~/.aws/credentials"
  allowed_account_ids     = ["${var.accounts_permission[terraform.workspace]}"]
}

provider "aws" {
  alias                   = "virginia"
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
}
