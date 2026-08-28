resource "tailscale_federated_identity" "homelab_federated_identity" {
  description = "Github federated identity"
  scopes      = ["auth_keys", "devices:core"]
  tags        = var.taiscale_tags
  issuer      = var.tailscale_issuer
  subject     = var.tailscale_subject
  custom_claim_rules = {
    repository = "andrelucasti/homelab"
  }
}
