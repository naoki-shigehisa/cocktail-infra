variable "my_ip" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}
variable "database_name" {}
variable "database_username" {}
variable "database_password" {}
variable "host_domain_name" {}
variable "domain_name" {}
variable "ec2_public_key" {}

# 作成するリソースのプレフィックス
variable "r_prefix" {
  default = "cocktail"
}
