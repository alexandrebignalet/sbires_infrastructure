terraform {
  backend "s3" {
    shared_credentials_file = "~/.aws/credentials"
    bucket                  = "sbires-terraform-state"
    region                  = "eu-west-1"
    key                     = "state"
  }
}
