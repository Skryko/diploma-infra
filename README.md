# diploma-infra

Terraform-конфигурация инфраструктуры в Yandex Cloud для дипломного
практикума.

## Структура

- `bootstrap_yc/` — начальная конфигурация:
  - сервисный аккаунт с ролями (compute.editor, container-registry.editor,
    storage.admin, vpc.admin, vpc.publicAdmin)
  - авторизованный ключ SA
  - статический ключ S3
  - бакет для Terraform state с версионированием
- `infrastructure_yc/` — основная инфраструктура:
  - VPC с тремя подсетями в зонах ru-central1-a, -b, -d
  - security group для Kubernetes (SSH/6443 только с admin_cidrs,
    80/443 из интернета, весь трафик внутри группы)
  - 3 ВМ: k8s-control-plane (непрерываемая) + 2 preemptible worker
  - Yandex Container Registry + IAM-привязки для push/pull

## Backend

State хранится в Yandex Object Storage:
- bucket: tfstate-b1gh2799rqen7aeoco0j
- key: infrastructure/terraform.tfstate
- блокировка state отсутствует (для одновременных запусков учитывать)

## CI/CD (GitHub Actions)

Workflow `.github/workflows/terraform.yml`:

- pull_request → terraform fmt/init/validate/plan + комментарий плана в PR
- push в main → init/validate/plan/apply

Переменные (секреты GitHub):

- YC_SA_KEY_JSON — SA-ключ Yandex Cloud
- S3_ACCESS_KEY / S3_SECRET_KEY — статические ключи для backend
- YC_CLOUD_ID / YC_FOLDER_ID — реквизиты
- ADMIN_CIDRS — список CIDR в формате HCL: ["1.2.3.4/32"]
- SSH_PUBLIC_KEY — публичный SSH-ключ для ВМ

Workflow на каждом запуске генерирует terraform.tfvars из секретов
и удаляет его вместе с /tmp/secrets после завершения.

## Применение локально

  cd infrastructure_yc
  terraform init
  terraform plan -out=tf.plan
  terraform apply tf.plan

Для локального запуска нужны env:
- YC_SERVICE_ACCOUNT_KEY_FILE=<путь к SA JSON>
- AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (для S3 backend)
- terraform.tfvars на основе terraform.tfvars.example

## Особенности

- image_id зафиксирован хардкодом в compute.tf, чтобы data-источник
  не триггерил замену ВМ при обновлении образа в family.
- IAM-привязки на Yandex Container Registry создаются как ресурсы
  (yandex_container_registry_iam_binding). Для этого SA Terraform
  должен иметь роль container-registry.admin на каталог — назначается
  один раз вручную.
- Прерываемые worker-узлы могут останавливаться Yandex Cloud. При
  остановке внешний IP меняется, но внутренний остаётся. См. diploma-ansible.

## Полный destroy/apply

Задание требует воспроизводимого цикла:

  terraform destroy
  terraform apply

Цикл проверен: после destroy создаются все 8 ресурсов, повторный plan
показывает No changes.
