terraform {
    required_providers {
        multipass = {
            source = "todoroff/multipass"
        }
        
    }
}

provider "multipass" {
    
}

resource "multipass_instance" "k8s-master" {
    name = "k8s-master"
    cpus = "2"
    memory = "4G"
    image  = "24.04"
    disk = "20G"
}