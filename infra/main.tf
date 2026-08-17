terraform {
    required_providers {
        multipass = {
            source = "todoroff/multipass"
        }

    }
}

resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

provider "multipass" {
    
}

resource "multipass_instance" "k8s-master" {
    name = "k8s-master"
    cpus = "2"
    memory = "4G"
    image  = "24.04"
    disk = "20G"
    cloud_init = templatefile("${path.module}/cloud_init/master.yaml.tpl",{
        k3s_token         = random_password.k3s_token.result
        tailscale_authkey = var.tailscale_authkey

    })

    wait_for_cloud_init = true
}

resource "multipass_instance" "k8s-worker" {
    count = 2
    name = "k8s-worker-${count.index}"
    cpus = "2"
    memory = "4G"
    disk = "20G"
    cloud_init = templatefile("${path.module}/cloud_init/worker.yaml.tpl",{
        master_ip = multipass_instance.k8s-master.ipv4[0]
        k3s_token = random_password.k3s_token.result

    })

    depends_on = [ multipass_instance.k8s-master ]
  
}

output "master_ip" {
    value = multipass_instance.k8s-master.ipv4[0]
}