provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Update with your kubeconfig path
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"  # Update with your kubeconfig path
}

variable "eks_cluster_name" {
  default = "your-eks-cluster-name"  # Update with your EKS cluster name
}

# Data source to fetch EKS cluster OIDC issuer URL
data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = var.argocd_k8s_namespace

  values = [
    # Update with additional values as needed
  ]

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.config.enabled"
    value = "true"
  }

  set {
    name  = "server.name"
    value = "argocd-server"
  }

  # Set the EKS OIDC issuer URL for ArgoCD
  set {
    name  = "server.oidc.config.issuer"
    value = data.aws_eks_cluster.eks.identity.0.oidc.0.issuer
  }

  depends_on = [
    data.aws_eks_cluster.eks,
  ]
}
