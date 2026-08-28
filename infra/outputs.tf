output "master_ip" {
  value = multipass_instance.k8s-master.ipv4[0]  
}
