variable "project_name" {}
variable "cluster_name" {}
variable "aws_region" {}
variable "cluster_role_arn" {}
variable "node_role_arn" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
