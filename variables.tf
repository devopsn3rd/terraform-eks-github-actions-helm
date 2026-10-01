variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-resume-cluster"
}

variable "project_name" {
  description = "Project name — used by modules/vpc, modules/iam, and modules/eks for resource naming/tagging"
  type        = string
  default     = "eks-resume-project"
}
