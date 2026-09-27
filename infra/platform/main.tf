module "plataform" {
  source = "../modules/platform"
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}
