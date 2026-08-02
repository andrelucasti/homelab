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
    image = "lts"
    cpus = "2"
    memory = "4G"
    disk = "20G"
    cloud_init_file = "cloud-init/master.yaml"
  
}