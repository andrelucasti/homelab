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
    - curl -sfL https://get.k3s.io | K3S_TOKEN=${k3s_token} sh -

    # --- Tailscale ---
    - curl -fsSL https://tailscale.com/install.sh | sh
    - systemctl enable --now tailscaled
    - tailscale up --authkey="$(cat /run/tailscale-authkey)" --hostname=$(hostname) --accept-dns=false
    - rm -f /run/tailscale-authkey
