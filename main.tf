# --- Infrastructure re-used from Project 1: VPC, IAM, EKS cluster ---
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  cluster_name = var.cluster_name
  # vpc_cidr / public_subnet_cidrs / private_subnet_cidrs default inside the module —
  # pass them here only if you want different ranges than 10.0.0.0/16 / .1.0,.2.0 / .11.0,.12.0
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "eks" {
  source             = "./modules/eks"
  project_name       = var.project_name
  cluster_name       = var.cluster_name
  aws_region         = var.region
  cluster_role_arn   = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

# --- ECR repository ---
resource "aws_ecr_repository" "orders_api" {
  name                 = "orders-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "orders_api" {
  repository = aws_ecr_repository.orders_api.name
  policy     = file("${path.module}/ecr-lifecycle-policy.json")
}

# --- GitHub OIDC provider ---
resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# --- IAM role GitHub Actions assumes ---
# Replace <OWNER>, <OWNER_ID>, <REPO>, <REPO_ID> — see the OIDC guide, Section 3.2.2,
# for how to look these up. Use the legacy sub format (Section 3.2.4) instead if your
# repo predates 15 Jul 2026 and hasn't opted into the immutable format.
resource "aws_iam_role" "github_actions_deploy" {
  name = "github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github_actions.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:devopsn3rd@68311196/terraform-eks-github-actions-helm@1400776705:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "github_actions_permissions" {
  name   = "github-actions-deploy-policy"
  policy = file("${path.module}/github-actions-iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.github_actions_permissions.arn
}

# --- Map the role into cluster RBAC ---
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.github_actions_deploy.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.github_actions_deploy.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["default"]
  }
}
