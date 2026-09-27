terraform {
  required_version = ">= 1.6"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
    }
  }
}

locals {
  kubeconfig_path = var.kubeconfig_path != null ? pathexpand(var.kubeconfig_path) : abspath("${path.root}/../.generated/kubeconfig.yaml")
}

provider "kubernetes" {
  config_path = local.kubeconfig_path
}

provider "helm" {
  kubernetes = {
    config_path = local.kubeconfig_path
  }
}
