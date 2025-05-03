module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.36"

  cluster_name    = var.cluster_name
  cluster_version = "1.28"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Fargate Profiles
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
      subnet_ids = module.vpc.private_subnets
      tags = {
        Environment = var.environment
      }
    }
    applications = {
      name = "applications"
      selectors = [
        {
          namespace = "applications"
        }
      ]
      subnet_ids = module.vpc.private_subnets
      tags = {
        Environment = var.environment
      }
    }
  }

  # Create EKS Managed Node Group(s)
  eks_managed_node_groups = {}

  # Configure AWS Auth for Fargate
  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# Coredns Fargate configuration
resource "kubernetes_namespace" "applications" {
  depends_on = [module.eks]
  metadata {
    name = "applications"
  }
}

# Configure CoreDNS to run on Fargate
# This part is typically handled in a post-deployment step via kubectl
# as part of a complete EKS Fargate deployment