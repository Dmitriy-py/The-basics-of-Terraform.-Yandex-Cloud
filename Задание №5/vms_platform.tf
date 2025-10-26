# --- VARIABLES FOR WEB VM (VM 1) ---

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

# --- VARIABLES FOR DB VM (VM 2) ---

variable "vm_db_name" {
  description = "Name for the DB VM instance"
  type        = string
  default     = "netology-develop-platform-db"
}

variable "vm_db_zone" {
  description = "Zone for the DB VM"
  type        = string
  default     = "ru-central1-b"
}

variable "vm_db_cores" {
  description = "Number of CPU cores for DB VM"
  type        = number
  default     = 2
}

variable "vm_db_memory" {
  description = "Memory size in GB for DB VM"
  type        = number
  default     = 2
}

variable "vm_db_core_fraction" {
  description = "Guaranteed core fraction for DB VM"
  type        = number
  default     = 20
}

variable "vm_db_platform_id" {
  description = "Platform ID for the DB VM (reuse standard-v2)"
  type        = string
  default     = "standard-v2"
}

variable "vm_db_image_id" {
  description = "Image ID or family for the DB boot disk"
  type        = string
  default     = "fd86rorl7r6l2nq3ate6"
}

variable "vm_db_disk_size" {
  description = "Size of the DB boot disk in GB"
  type        = number
  default     = 30
}

variable "vm_db_disk_type" {
  description = "Type of the DB network disk"
  type        = string
  default     = "network-hdd"
}
