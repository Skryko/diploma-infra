locals {
  subnets = {
    a = {
      name = "k8s-subnet-a"
      zone = "ru-central1-a"
      cidr = "10.10.1.0/24"
    }
    b = {
      name = "k8s-subnet-b"
      zone = "ru-central1-b"
      cidr = "10.10.2.0/24"
    }
    d = {
      name = "k8s-subnet-d"
      zone = "ru-central1-d"
      cidr = "10.10.3.0/24"
    }
  }

  nodes = {
    k8s-control-plane = {
      role          = "control-plane"
      subnet_key    = "a"
      cores         = 2
      core_fraction = 20
      memory        = 4
      disk_size     = 30
      preemptible   = false
    }
    k8s-worker-1 = {
      role          = "worker"
      subnet_key    = "b"
      cores         = 2
      core_fraction = 20
      memory        = 4
      disk_size     = 30
      preemptible   = true
    }
    k8s-worker-2 = {
      role          = "worker"
      subnet_key    = "d"
      cores         = 2
      core_fraction = 20
      memory        = 4
      disk_size     = 30
      preemptible   = true
    }
  }
}
