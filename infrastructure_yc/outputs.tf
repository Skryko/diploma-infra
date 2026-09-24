output "network_id" {
  description = "Идентификатор сети Kubernetes"
  value       = yandex_vpc_network.kubernetes.id
}

output "subnets" {
  description = "Подсети Kubernetes по зонам доступности"

  value = {
    for key, subnet in yandex_vpc_subnet.kubernetes : key => {
      id   = subnet.id
      name = subnet.name
      zone = subnet.zone
      cidr = subnet.v4_cidr_blocks[0]
    }
  }
}

output "nodes" {
  description = "Адреса и параметры узлов Kubernetes"

  value = {
    for name, instance in yandex_compute_instance.kubernetes : name => {
      role        = local.nodes[name].role
      zone        = instance.zone
      internal_ip = instance.network_interface[0].ip_address
      external_ip = instance.network_interface[0].nat_ip_address
      preemptible = local.nodes[name].preemptible
    }
  }
}

output "ssh_commands" {
  description = "Команды для SSH-подключения к узлам"

  value = {
    for name, instance in yandex_compute_instance.kubernetes :
    name => "ssh ${var.ssh_username}@${instance.network_interface[0].nat_ip_address}"
  }
}

output "registry_id" {
  value       = yandex_container_registry.app.id
  description = "Yandex Container Registry ID"
}

output "registry_url" {
  value       = "cr.yandex/${yandex_container_registry.app.id}"
  description = "Base URL для docker push/pull"
}

