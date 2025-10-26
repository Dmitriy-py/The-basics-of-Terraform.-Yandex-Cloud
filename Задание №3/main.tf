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

# ----------------------------------------
# --- VM 1: WEB SERVER (ru-central1-a) ---
# ----------------------------------------
resource "yandex_compute_instance" "vm_web" {
  name                      = var.vm_web_name
  folder_id                 = var.folder_id
  zone                      = var.subnet_zone
  platform_id               = var.vm_web_platform_id
  service_account_id        = yandex_iam_service_account.sa.id
  
  # Установка hostname = имени ВМ
  hostname                  = var.vm_web_name 
  
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


# ----------------------------------------------------
# --- Подсеть для VM 2 (DB) в ru-central1-b ---
# ----------------------------------------------------
resource "yandex_vpc_subnet" "subnet_db" {
  name           = "default-subnet-db"
  zone           = var.vm_db_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.1.0.0/16"] 
}

# ----------------------------------------------------
# --- VM 2: DB SERVER (netology-develop-platform-db) ---
# ----------------------------------------------------
resource "yandex_compute_instance" "vm_db" {
  name                      = var.vm_db_name
  folder_id                 = var.folder_id
  zone                      = var.vm_db_zone # ru-central1-b
  platform_id               = var.vm_db_platform_id
  service_account_id        = yandex_iam_service_account.sa.id

  # Установка hostname = имени ВМ
  hostname                  = var.vm_db_name 
  
  network_interface {
    subnet_id           = yandex_vpc_subnet.subnet_db.id 
    nat                 = true 
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.vms_ssh_public_key_path)}"
  }

  boot_disk {
    initialize_params {
      image_id     = var.vm_db_image_id
      size         = var.vm_db_disk_size
      type         = var.vm_db_disk_type
    }
  }

  resources {
    memory        = var.vm_db_memory
    cores         = var.vm_db_cores
    core_fraction = var.vm_db_core_fraction # core_fraction = 20
  }

  scheduling_policy {
    preemptible = false 
  }
}


# --- Выводы ---
output "vm_web_external_ip" {
  description = "External IP address of the WEB VM"
  value       = yandex_compute_instance.vm_web.network_interface[0].nat_ip_address
}

output "vm_db_external_ip" {
  description = "External IP address of the DB VM"
  value       = yandex_compute_instance.vm_db.network_interface[0].nat_ip_address
}
