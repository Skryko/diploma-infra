data "yandex_compute_image" "ubuntu" {
  family    = "ubuntu-2204-lts"
  folder_id = "standard-images"
}

resource "yandex_compute_instance" "kubernetes" {
  for_each = local.nodes

  name                      = each.key
  hostname                  = each.key
  description               = "Узел ${each.value.role} учебного Kubernetes-кластера"
  platform_id               = "standard-v3"
  zone                      = local.subnets[each.value.subnet_key].zone
  allow_stopping_for_update = true

  resources {
    cores         = each.value.cores
    core_fraction = each.value.core_fraction
    memory        = each.value.memory
  }

  boot_disk {
    auto_delete = true

    initialize_params {
      image_id = "fd85n2sh0jr400ph4b8u"
      type     = "network-hdd"
      size     = each.value.disk_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.kubernetes[each.value.subnet_key].id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kubernetes.id]
  }

  scheduling_policy {
    preemptible = each.value.preemptible
  }

  metadata = {
    "serial-port-enable" = "0"
    "ssh-keys"           = "${var.ssh_username}:${trimspace(file(var.ssh_public_key_path))}"
  }

  labels = {
    environment = "homework"
    role        = each.value.role
  }
}
