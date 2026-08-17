#cloud-config
package_update: true

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - containerd

write_files:
  - path: /run/tailscale-authkey
    permissions: '0600'
    owner: root:root
    content: "${tailscale_authkey}"

runcmd:
    - curl -sfL https://get.k3s.io -o /tmp/k3s-install.sh || { echo "ERRO - download do instalador do k3s falhou" >&2; exit 1; }
    - K3S_TOKEN=${k3s_token} sh /tmp/k3s-install.sh || { echo "ERRO - instalacao do k3s server falhou" >&2; exit 1; }

    # --- Tailscale ---
    - curl -fsSL https://tailscale.com/install.sh | sh
    - systemctl enable --now tailscaled
    - tailscale up --authkey="$(cat /run/tailscale-authkey)" --hostname=$(hostname) --accept-dns=false || { echo "ERRO - tailscale up falhou" >&2; rm -f /run/tailscale-authkey; exit 1; }
    - rm -f /run/tailscale-authkey
