resource "yandex_container_registry" "app" {
  name      = "diploma-app"
  folder_id = var.folder_id
  labels = {
    project = "diploma"
  }
}

resource "yandex_container_registry_iam_binding" "push" {
  registry_id = yandex_container_registry.app.id
  role        = "container-registry.images.pusher"
  members     = ["serviceAccount:${var.service_account_id}"]
}

resource "yandex_container_registry_iam_binding" "pull" {
  registry_id = yandex_container_registry.app.id
  role        = "container-registry.images.puller"
  members     = ["serviceAccount:${var.service_account_id}"]
}
