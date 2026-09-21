module "homelab_cluster" {
  source = "./modules/provisioner"
  cpus = "2"
  memory = "4G"
  disk   = "10G"
  workers = 3
}