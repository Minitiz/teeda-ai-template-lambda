terraform {
  backend "s3" {
    bucket         = "terraform-bucket-test-207567778821"
    key            = "tfstate-dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-lock-table-test-207567778821" # Lock table created by Terraform
  }
}
