resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

resource "multipass_instance" "k8s-master" {
  name   = "k8s-master"
  cpus   = "2"
  memory = "4G"
  image  = "24.04"
  disk   = "20G"
  cloud_init = templatefile("${path.module}/cloud_init/master.yaml.tpl", {
    k3s_token         = random_password.k3s_token.result
    tailscale_authkey = var.tailscale_authkey

  })

  wait_for_cloud_init = true
}

resource "multipass_instance" "k8s-worker" {
  count  = 2
  name   = "k8s-worker-${count.index}"
  cpus   = "2"
  image  = "24.04"
  memory = "4G"
  disk   = "20G"
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

resource "local_sensitive_file" "kubeconfig" {
  content         = data.external.kubeconfig.result.raw
  filename        = "${path.module}/${var.kubeconfig_path}"
  file_permission = "0600"
}

resource "helm_release" "cert_manager" {
  name  = "cert-manager"
  chart = "cert-manager"
  repository = "https://charts.jetstack.io"
  version = "v1.21.1"
  namespace = "cert-manager"
  create_namespace = true

  set = [ 
        { name = "crds.enabled", value = "true" },
        { name = "crds.keep", value = "true"} 
    ]

    wait = true
    timeout = 600
}

resource "helm_release" "otel_operator" {
  name = "opentelemetry-operator"
  chart = "opentelemetry-operator"
  namespace = "observability"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  create_namespace = true

  set = [ 
        { name = "manager.collectorImage.repository", value = "otel/opentelemetry-collector-k8s" },
        { name = "admissionWebhooks.certManager.enabled", value = "false" },
        { name = "admissionWebhooks.autoGenerateCert.enabled", value = "true" } 
    ]
    
    wait = true
    upgrade_install = true
    atomic = true
    cleanup_on_fail = true
    depends_on = [ helm_release.cert_manager ]
}

resource "helm_release" "otel_workloads" {
    name = "otel-workloads"
    namespace = "observability"
    chart = "${path.module}/charts/otel-workloads"

    wait = true
    upgrade_install = true

    depends_on = [ helm_release.otel_operator ]
}