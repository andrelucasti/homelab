output "ts_oauth_client_id" {
  description = "Value for the TS_OAUTH_CLIENT_ID GitHub Actions secret"
  value       = tailscale_federated_identity.homelab_federated_identity.id
}

output "ts_audience" {
  description = "Value for the TS_AUDIENCE GitHub Actions secret"
  value       = tailscale_federated_identity.homelab_federated_identity.audience
}
