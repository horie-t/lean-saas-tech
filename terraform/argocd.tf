# ArgoCD Installation using Helm

# Create a Fargate profile for ArgoCD namespace
resource "aws_eks_fargate_profile" "argocd" {
  cluster_name           = var.cluster_name
  fargate_profile_name   = "argocd"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = module.vpc.private_subnets

  selector {
    namespace = "argocd"
  }

  tags = var.tags
}

# Install ArgoCD using Helm chart
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "8.0.3"  # Specify a version for stability
  namespace  = "argocd"
  create_namespace = true

  # Wait for the Fargate profile to be ready before installing ArgoCD
  depends_on = [aws_eks_fargate_profile.argocd]

  # Basic values for ArgoCD
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Configure resources to work well with Fargate
  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "2Gi"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "300m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "512Mi"
  }

  set {
    name  = "server.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "server.resources.limits.memory"
    value = "2Gi"
  }

  set {
    name  = "server.resources.requests.cpu"
    value = "300m"
  }

  set {
    name  = "server.resources.requests.memory"
    value = "512Mi"
  }

  # Set initial admin password as randomly generated
  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = ""  # Empty string means a random password will be generated
  }

  # Enable metrics for monitoring
  set {
    name  = "server.metrics.enabled"
    value = "true"
  }
}

# Output command to get the ArgoCD server URL
output "argocd_server_url_command" {
  description = "Command to get the URL of the ArgoCD server"
  value       = "kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
  depends_on  = [helm_release.argocd]
}

# Output command to get the initial admin password
output "argocd_admin_password_command" {
  description = "Command to get the initial admin password for ArgoCD"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  depends_on  = [helm_release.argocd]
}
