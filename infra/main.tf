module "homelab_cluster" {
  source = "./modules/cluster"
  cpus = "2"
  memory = "4G"
  disk   = "10G"
  workers = 3
}

module "plataform" {
  source = "./modules/plataform"
}