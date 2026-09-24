locals {
  terraform_service_account_roles = toset([
    "compute.editor",
    "container-registry.editor",
    "storage.admin",
    "vpc.admin",
    "vpc.publicAdmin"
  ])
}

resource "yandex_iam_service_account" "terraform" {
  folder_id   = var.folder_id
  name        = var.service_account_name
  description = "Сервисный аккаунт для управления учебной инфраструктурой через Terraform"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_roles" {
  for_each = local.terraform_service_account_roles

  folder_id = var.folder_id
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

resource "yandex_iam_service_account_key" "terraform" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "Авторизованный ключ для провайдера Yandex Cloud"
  key_algorithm      = "RSA_4096"
}

resource "yandex_iam_service_account_static_access_key" "terraform_state" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "Статический ключ для доступа к Terraform state в Object Storage"
}

resource "yandex_storage_bucket" "terraform_state" {
  access_key = yandex_iam_service_account_static_access_key.terraform_state.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_state.secret_key

  bucket        = var.state_bucket_name
  folder_id     = var.folder_id
  force_destroy = false

  versioning {
    enabled = true
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.terraform_roles
  ]
}