############################################
# Terraform Backend + Providers
############################################
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

############################################
# Run Minikube (via local-exec)
############################################
resource "null_resource" "minikube" {
  triggers = {
    always_run = timestamp()
  }

  # Start Minikube
  provisioner "local-exec" {
    command = <<-EOT
      echo "[Starting Minikube]"
      minikube start --driver=docker --kubernetes-version=v1.34.0 --cpus=2 --memory=4096 --addons=default-storageclass,storage-provisioner
    EOT

    # Increase timeout for Minikube startup (default is 5 minutes)
    interpreter = ["/bin/sh", "-c"]
    timeout     = "10m"
  }

  # Delete Minikube on terraform destroy
  provisioner "local-exec" {
    when    = destroy
    command = "minikube delete"
  }
}

############################################
# Kubernetes Provider (connected to Minikube)
############################################
provider "kubernetes" {
  config_path = "~/.kube/config"

  # Ensure Minikube is started *before* using Kubernetes provider
  alias = "mk"
}

############################################
# Example Kubernetes Resource
############################################
resource "kubernetes_namespace" "example" {
  provider = kubernetes.mk

  metadata {
    name = "dev"
  }

  depends_on = [null_resource.minikube]
}
