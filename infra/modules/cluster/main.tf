resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

resource "multipass_instance" "k8s-master" {
  name   = "k8s-master"
  cpus   = var.cpus
  memory = var.memory
  image  = "24.04"
  disk   = var.disk
  cloud_init = templatefile("${path.module}/cloud_init/master.yaml.tpl", {
    k3s_token         = random_password.k3s_token.result
    tailscale_authkey = var.tailscale_authkey

  })

  wait_for_cloud_init = true
}

resource "multipass_instance" "k8s-worker" {
  count  = var.workers
  name   = "k8s-worker-${count.index}"
  cpus   = var.cpus
  image  = "24.04"
  memory = var.memory
  disk   = var.disk
  cloud_init = templatefile("${path.module}/cloud_init/worker.yaml.tpl", {
    master_ip         = multipass_instance.k8s-master.ipv4[0]
    k3s_token         = random_password.k3s_token.result
    tailscale_authkey = var.tailscale_authkey

  })

  depends_on = [multipass_instance.k8s-master]

}

data "external" "kubeconfig" {
  depends_on = [multipass_instance.k8s-master]
  

  program = ["bash", "-c", <<-EOT
    set -euo pipefail

    TS_IP=$(multipass exec k8s-master -- tailscale ip -4 | tr -d '\r\n')
    [ -n "$TS_IP" ] || { echo "tailscale nao retornou IPv4 no master" >&2; exit 1; }

    KC=$(multipass exec k8s-master -- sudo cat /etc/rancher/k3s/k3s.yaml \
         | sed "s#127\.0\.0\.1#$TS_IP#")

    jq -n --arg raw "$KC" '{raw: $raw}'
  EOT
  ]
}