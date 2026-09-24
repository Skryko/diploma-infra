resource "yandex_vpc_network" "kubernetes" {
  name        = "k8s-network"
  description = "Сеть учебного Kubernetes-кластера"
}

resource "yandex_vpc_subnet" "kubernetes" {
  for_each = local.subnets

  name           = each.value.name
  description    = "Подсеть Kubernetes в зоне ${each.value.zone}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.kubernetes.id
  v4_cidr_blocks = [each.value.cidr]
}

resource "yandex_vpc_security_group" "kubernetes" {
  name        = "k8s-security-group"
  description = "Правила доступа к учебному Kubernetes-кластеру"
  network_id  = yandex_vpc_network.kubernetes.id

  ingress {
    description       = "Весь трафик между узлами кластера"
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }

  ingress {
    description    = "SSH только с административных адресов"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.admin_cidrs
  }

  ingress {
    description    = "Kubernetes API только с административных адресов"
    protocol       = "TCP"
    port           = 6443
    v4_cidr_blocks = var.admin_cidrs
  }

  ingress {
    description    = "ICMP только с административных адресов"
    protocol       = "ICMP"
    v4_cidr_blocks = var.admin_cidrs
  }

  ingress {
    description    = "HTTP для будущего Ingress"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTPS для будущего Ingress"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Исходящий трафик в интернет"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
