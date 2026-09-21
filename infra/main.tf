module "homelab_cluster" {
  source = "./modules/provisioner"
  cpus = "2"
  memory = "4G"
  disk   = "10G"
  workers = 3
}

/* resource "helm_release" "cert_manager" {
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
} */