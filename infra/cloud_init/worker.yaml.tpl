#cloud-config
package_update: true

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - containerd

runcmd:
    - curl -sfL https://get.k3s.io -o /tmp/k3s-install.sh || { echo "ERRO - download do instalador do k3s falhou" >&2; exit 1; }
    - K3S_URL=https://${master_ip}:6443 K3S_TOKEN=${k3s_token} sh /tmp/k3s-install.sh || { echo "ERRO - instalacao do k3s agent falhou" >&2; exit 1; }
    