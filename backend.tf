terraform {
  backend "s3" {
    bucket  = "my-eks-project-tfstate-levpdevops"
    key     = "eks-project-2/terraform.tfstate"
    region  = "us-east-1"
    profile = "terraform-deployer"
  }
}
