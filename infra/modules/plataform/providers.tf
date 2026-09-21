terraform {
  required_version = ">= 1.6"
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
    
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~>3.2"
    }
    
  }
}


provider "kubernetes" {
  config_path = "${path.module}/${var.kubeconfig_path}"
}

provider "helm" {
  kubernetes = {
    config_path = "${path.module}/${var.kubeconfig_path}"
  }
}