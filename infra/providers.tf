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
    config_paths = var.kubeconfig_path 
}