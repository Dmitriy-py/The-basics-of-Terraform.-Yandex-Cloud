# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»

## ` Дмитрий Климов `

## Задание 1

В качестве ответа всегда полностью прикладывайте ваш terraform-код в git. Убедитесь что ваша версия Terraform ~>1.12.0

1. Изучите проект. В файле variables.tf объявлены переменные для Yandex provider.
2. Создайте сервисный аккаунт и ключ. service_account_key_file.
3. Сгенерируйте новый или используйте свой текущий ssh-ключ. Запишите его открытую(public) часть в переменную vms_ssh_public_root_key.
4. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте, в чём заключается их суть.
5. Подключитесь к консоли ВМ через ssh и выполните команду  curl ifconfig.me. Примечание: К OS ubuntu "out of a box, те из коробки" необходимо подключаться под пользователем ubuntu: "ssh ubuntu@vm_ip_address". Предварительно убедитесь, что ваш ключ добавлен в ssh-агент: eval $(ssh-agent) && ssh-add Вы познакомитесь с тем как при создании ВМ создать своего пользователя в блоке metadata в следующей лекции.;
6. Ответьте, как в процессе обучения могут пригодиться параметры preemptible = true и core_fraction=5 в параметрах ВМ.

В качестве решения приложите:

скриншот ЛК Yandex Cloud с созданной ВМ, где видно внешний ip-адрес;
скриншот консоли, curl должен отобразить тот же внешний ip-адрес;
ответы на вопросы.

## Ответ:

 ### ` main.tf `

 ```terraform
# main.tf

# --- Yandex Provider and Terraform Core Setup ---
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      # Оставляем пустым, чтобы Terraform выбрал последнюю доступную версию
    }
  }
  required_version = ">= 1.13.0"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}

# --- Сервисный аккаунт и ключ ---
resource "yandex_iam_service_account" "sa" {
  name        = "vm-creator-sa"
  folder_id   = var.folder_id
  description = "Service account for creating VMs"
}

resource "yandex_iam_service_account_key" "sa_key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "Key for VM creator SA"
}

# --- Сеть и подсеть ---
resource "yandex_vpc_network" "network" {
  name = "default-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "default-subnet"
  zone           = var.subnet_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.0.0/16"]
}

# --- Группа безопасности (Firewall) ---
resource "yandex_vpc_security_group" "allow_ssh" {
  name        = "allow-ssh"
  network_id  = yandex_vpc_network.network.id
  description = "Allow SSH access"

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from anywhere"
    from_port      = 22
    to_port        = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all egress traffic"
    from_port      = 0
    to_port        = 0
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Виртуальная машина ---
resource "yandex_compute_instance" "vm" {
  name                      = "my-vm"
  hostname                  = "my-vm"
  folder_id                 = var.folder_id
  zone                      = var.subnet_zone
  platform_id               = "standard-v2"
  service_account_id        = yandex_iam_service_account.sa.id
  
  network_interface {
    subnet_id           = yandex_vpc_subnet.subnet.id
    
    # Включаем публичный IP (NAT). Синтаксис nat=true сработал в v0.168.0.
    nat                 = true 
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.vms_ssh_public_key_path)}"
  }

  boot_disk {
    initialize_params {
      # Использование image_id для корректного выбора образа
      image_id = "fd86rorl7r6l2nq3ate6" 
      size     = 30
      type     = "network-hdd"
    }
  }

  resources {
    memory = 2
    cores  = 2
  }

  scheduling_policy {
    preemptible = true 
  }
}

# --- Вывод внешнего IP-адреса ---
output "vm_external_ip" {
  description = "External IP address of the VM"
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

# --- Вывод сервисного аккаунта ключа ---
output "service_account_key" {
  description = "Service account key"
  value       = yandex_iam_service_account_key.sa_key.id
  sensitive   = true
}
```

### ` variables.tf `
```terraform
# variables.tf

variable "service_account_key_file" {
  description = "Path to the service account key file"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "subnet_zone" {
  description = "Zone for the VM and subnet"
  type        = string
  default     = "ru-central1-a"
}

variable "vms_ssh_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
}
```

<img width="1920" height="1080" alt="Снимок экрана (1677)" src="https://github.com/user-attachments/assets/59c77bc5-989d-4b17-9e03-f3ca2b595b8e" />

<img width="1920" height="1080" alt="Снимок экрана (1676)" src="https://github.com/user-attachments/assets/0f7d535a-3a87-4ade-9102-ec1627c1c05d" />

<img width="1920" height="1080" alt="Снимок экрана (1675)" src="https://github.com/user-attachments/assets/f2b0524c-1695-4b18-a888-d3c203a6da41" />


### 1. В чём заключается суть намеренно допущенных синтаксических ошибок?

### Сложности возникли из-за комбинации намеренных ошибок и конфликтов версий:

```terraform
Конфликт версий провайдера (v0.168.0): Исходный код использовал современный синтаксис (например, блок nat {}, аргумент security_groups внутри network_interface), который не поддерживался выбранной Terraform версией провайдера. Это потребовало ручной адаптации синтаксиса (например, использование nat = true и исключение привязки Security Group из блока ВМ).
Неправильные ссылки на ресурсы/атрибуты: Использование несуществующего ресурса yandex_compute_address для получения IP и некорректная ссылка на атрибут VPC default_route_table_id.
Некорректный ID образа: Использование короткого имени (image_id = "ubuntu-2004-lts") вместо image_id = "fd86rorl7r6l2nq3ate6" в блоке boot_disk, что приводило к ошибке API.
```

### 2. Как в процессе обучения могут пригодиться параметры preemptible = true и core_fraction=5 в параметрах ВМ?

```terraform
preemptible = true: Экономия средств для тестовых и лабораторных сред (прерываемые ВМ значительно дешевле) и возможность изучения отказоустойчивости. Разработчик учится проектировать системы, способные корректно обрабатывать внезапное прекращение работы инстанса.
core_fraction=5: Используется для создания виртуальных машин с низкой гарантированной производительностью (Burstable VMs). Полезно для оптимизации затрат и для тестирования приложений в условиях ограниченных вычислительных ресурсов, что помогает определить минимально необходимые требования к CPU.

```
## Ответ:

### ` main.tf `

```terraform
# main.tf

# --- Yandex Provider and Terraform Core Setup ---
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.13.0"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}

# --- Сервисный аккаунт и ключ ---
resource "yandex_iam_service_account" "sa" {
  name        = var.sa_name
  folder_id   = var.folder_id
  description = "Service account for creating VMs"
}

resource "yandex_iam_service_account_key" "sa_key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "Key for VM creator SA"
}

# --- Сеть и подсеть ---
resource "yandex_vpc_network" "network" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "subnet" {
  name           = var.subnet_name
  zone           = var.subnet_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = var.subnet_cidr_blocks
}

# --- Группа безопасности (Firewall) ---
resource "yandex_vpc_security_group" "allow_ssh" {
  name        = var.sg_name
  network_id  = yandex_vpc_network.network.id
  description = "Allow SSH access"

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from anywhere"
    from_port      = var.ssh_port
    to_port        = var.ssh_port
    v4_cidr_blocks = var.allowed_cidr_blocks_ssh
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all egress traffic"
    from_port      = 0
    to_port        = 0
    v4_cidr_blocks = var.allowed_cidr_blocks_ssh
  }
}

# --- Виртуальная машина ---
resource "yandex_compute_instance" "vm" {
  name                      = var.vm_web_name
  hostname                  = var.vm_web_name
  folder_id                 = var.folder_id
  zone                      = var.subnet_zone
  platform_id               = var.vm_web_platform_id
  service_account_id        = yandex_iam_service_account.sa.id
  
  network_interface {
    subnet_id           = yandex_vpc_subnet.subnet.id
    nat                 = true 
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.vms_ssh_public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image_id     = var.vm_web_image_id
      size         = var.vm_web_disk_size
      type         = var.vm_web_disk_type
    }
  }

  resources {
    memory = var.vm_web_memory
    cores  = var.vm_web_cores
  }

  scheduling_policy {
    preemptible = true 
  }
}

# --- Вывод внешнего IP-адреса ---
output "vm_external_ip" {
  description = "External IP address of the VM"
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

# --- Вывод сервисного аккаунта ключа ---
output "service_account_key" {
  description = "Service account key"
  value       = yandex_iam_service_account_key.sa_key.id
  sensitive   = true
}
```
### ` variables.tf `

```terraform
# --- Provider Credentials & General Config ---

variable "service_account_key_file" {
  description = "Path to the service account key file"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "subnet_zone" {
  description = "Zone for the VM and subnet"
  type        = string
  default     = "ru-central1-a"
}

variable "vms_ssh_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
}

# --- Task 2: VM INSTANCE VARIABLES (vm_web_ prefix) ---

variable "vm_web_name" {
  description = "Name for the web VM instance"
  type        = string
  default     = "my-vm"
}

variable "vm_web_platform_id" {
  description = "Platform ID for the VM"
  type        = string
  default     = "standard-v2"
}

variable "vm_web_image_id" {
  description = "Image ID or family for the boot disk"
  type        = string
  default     = "fd86rorl7r6l2nq3ate6"
}

variable "vm_web_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 30
}

variable "vm_web_disk_type" {
  description = "Type of the network disk"
  type        = string
  default     = "network-hdd"
}

variable "vm_web_memory" {
  description = "Memory size in GB"
  type        = number
  default     = 2
}

variable "vm_web_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

# --- Task 2: OTHER RESOURCE VARIABLES ---

variable "sa_name" {
  description = "Name for the Service Account"
  type        = string
  default     = "vm-creator-sa"
}

variable "network_name" {
  description = "Name for the VPC Network"
  type        = string
  default     = "default-network"
}

variable "subnet_name" {
  description = "Name for the VPC Subnet"
  type        = string
  default     = "default-subnet"
}

variable "subnet_cidr_blocks" {
  description = "CIDR block for the subnet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "sg_name" {
  description = "Name for the Security Group"
  type        = string
  default     = "allow-ssh"
}

variable "ssh_port" {
  description = "Port for SSH access"
  type        = number
  default     = 22
}

variable "allowed_cidr_blocks_ssh" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
```

<img width="1920" height="1080" alt="Снимок экрана (1678)" src="https://github.com/user-attachments/assets/da5141e2-dcf8-43ac-8d91-0a63b610ae95" />

### Задание 3

Создайте в корне проекта файл 'vms_platform.tf' . Перенесите в него все переменные первой ВМ.
Скопируйте блок ресурса и создайте с его помощью вторую ВМ в файле main.tf: "netology-develop-platform-db" , cores  = 2, memory = 2, core_fraction = 20. Объявите её переменные с префиксом vm_db_ в том же файле ('vms_platform.tf'). ВМ должна работать в зоне "ru-central1-b"
Примените изменения.

Ответ:

https://github.com/Dmitriy-py/The-basics-of-Terraform.-Yandex-Cloud/tree/main/%D0%97%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5%20%E2%84%963


























