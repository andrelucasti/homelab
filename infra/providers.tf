terraform {
  required_version = ">= 1.6"

  required_providers {
    multipass = {
      source  = "todoroff/multipass"
      version = "~> 1.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "multipass" {
}

provider "kubernetes" {
  config_path = "${path.module}/${var.kubeconfig_path}"
}
