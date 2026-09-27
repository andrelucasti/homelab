variable "kubeconfig_path" {
  description = "Override opcional para o caminho do kubeconfig. Por padrão usa o arquivo exportado pelo cluster."
  type        = string
  default     = null
  nullable    = true
}
