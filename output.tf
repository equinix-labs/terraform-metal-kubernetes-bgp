output "master_address" {
  value = [packet_device.k8s_controller.access_public_ipv4]
}

output "kubeadm_join_command" {
  value = [data.external.kubeadm_join.result["command"]]
}

output "worker_addresses" {
  value = [packet_device.k8s_workers.*.access_public_ipv4]
}

output "load_balancer_ips" {
  value = [packet_reserved_ip_block.load_balancer_ips.cidr_notation]
}
