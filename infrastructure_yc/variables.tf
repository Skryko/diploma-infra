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

variable "admin_cidrs" {
  description = "IPv4-сети, которым разрешены SSH и доступ к Kubernetes API"
  type        = list(string)

  validation {
    condition = length(var.admin_cidrs) > 0 && alltrue([
      for cidr in var.admin_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Укажите хотя бы одну корректную IPv4-сеть в формате CIDR."
  }
}

variable "ssh_public_key_path" {
  description = "Абсолютный путь к публичному SSH-ключу"
  type        = string

  validation {
    condition     = fileexists(var.ssh_public_key_path)
    error_message = "Публичный SSH-ключ по указанному пути не найден."
  }
}

variable "ssh_username" {
  description = "Имя пользователя Linux для SSH-подключения"
  type        = string
  default     = "ubuntu"

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]*$", var.ssh_username))
    error_message = "Имя пользователя SSH содержит недопустимые символы."
  }
}

variable "service_account_id" {
  type        = string
  description = "Service account ID (тот, от имени которого работает Terraform и CI)"
  default     = "aje2g81v6bh2mosr4up7"
}
