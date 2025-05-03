module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.36"
  cluster_version = "1.32"
  cluster_name    = "sample-cluster"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  enable_irsa               = true

  create_cluster_security_group = false
  create_node_security_group = false

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    # ここが大事
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

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
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
