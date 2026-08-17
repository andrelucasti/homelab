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
    # --- Tailscale ---
    - curl -fsSL https://tailscale.com/install.sh -o /tmp/tailscale-install.sh || { echo "ERRO - download do instalador do tailscale falhou" >&2; exit 1; }
    - sh /tmp/tailscale-install.sh || { echo "ERRO - instalacao do tailscale falhou" >&2; exit 1; }
    - systemctl enable --now tailscaled || { echo "ERRO - tailscaled nao subiu" >&2; exit 1; }
    - tailscale up --authkey="$(cat /run/tailscale-authkey)" --hostname=$(hostname) --accept-dns=false || { echo "ERRO - tailscale up falhou" >&2; rm -f /run/tailscale-authkey; exit 1; }
    - rm -f /run/tailscale-authkey
    - tailscale ip -4 || { echo "ERRO - tailscale nao atribuiu IPv4" >&2; exit 1; }

    # --- k3s agent ---
    - curl -sfL https://get.k3s.io -o /tmp/k3s-install.sh || { echo "ERRO - download do instalador do k3s falhou" >&2; exit 1; }
    - K3S_URL=https://${master_ip}:6443 K3S_TOKEN=${k3s_token} sh /tmp/k3s-install.sh || { echo "ERRO - instalacao do k3s agent falhou" >&2; exit 1; }
