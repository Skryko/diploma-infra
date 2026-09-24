output "terraform_service_account_id" {
  description = "Идентификатор сервисного аккаунта Terraform"
  value       = yandex_iam_service_account.terraform.id
}

output "state_bucket_name" {
  description = "Имя бакета, в котором будет храниться state основной инфраструктуры"
  value       = yandex_storage_bucket.terraform_state.bucket
}

output "authorized_key_json" {
  description = "JSON авторизованного ключа для аутентификации провайдера Yandex Cloud"
  sensitive   = true

  value = jsonencode({
    id                 = yandex_iam_service_account_key.terraform.id
    service_account_id = yandex_iam_service_account.terraform.id
    created_at         = yandex_iam_service_account_key.terraform.created_at
    key_algorithm      = "RSA_4096"
    public_key         = yandex_iam_service_account_key.terraform.public_key
    private_key        = yandex_iam_service_account_key.terraform.private_key
  })
}

output "s3_access_key" {
  description = "Идентификатор статического ключа для S3 backend"
  value       = yandex_iam_service_account_static_access_key.terraform_state.access_key
  sensitive   = true
}

output "s3_secret_key" {
  description = "Секретная часть статического ключа для S3 backend"
  value       = yandex_iam_service_account_static_access_key.terraform_state.secret_key
  sensitive   = true
}