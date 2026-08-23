terraform {
    required_providers {
        multipass = {
            source = "todoroff/multipass"
        }

    }
}

provider "multipass" {
    
}

provider "kubernetes" {
    config_path = var.kubeconfig_path 
}