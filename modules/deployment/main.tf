# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }
}


# Using Helm because is a package manager for k8s, and instead deploy a lot of manifests for argoCD,
# Helm manage the deploy with Helm chart (reusable templates that include all the necessary Kubernetes resources for deploying an application)
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.35.4"
  namespace  = "argocd"  

  force_update  = true
  replace       = true
  recreate_pods = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  depends_on = [kubernetes_namespace.argocd]
}


