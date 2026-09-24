variable "cloud_id" {
  description = "Идентификатор облака Yandex Cloud"
  type        = string

  validation {
    condition     = length(trimspace(var.cloud_id)) > 0
    error_message = "Переменная cloud_id не должна быть пустой."
  }
}

variable "folder_id" {
  description = "Идентификатор каталога Yandex Cloud"
  type        = string

  validation {
    condition     = length(trimspace(var.folder_id)) > 0
    error_message = "Переменная folder_id не должна быть пустой."
  }
}

variable "service_account_name" {
  description = "Имя сервисного аккаунта Terraform"
  type        = string
  default     = "terraform-sa"
}

variable "state_bucket_name" {
  description = "Глобально уникальное имя бакета для Terraform state"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "Имя бакета должно содержать от 3 до 63 строчных латинских букв, цифр, точек или дефисов."
  }
}