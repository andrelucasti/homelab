package_update: true

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - containerd
  - curl

runcmd:
    - curl -sfL https://get.k3s.io | K3S_TOKEN=${k3s_token} sh -

    