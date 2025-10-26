# vms_platform.tf

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

# --- UNUSED VARIABLES (Перенесены в vms_resources) ---
# variable "vm_web_disk_size" { ... }
# variable "vm_web_disk_type" { ... }
# variable "vm_web_memory" { ... }
# variable "vm_web_cores" { ... }
# --------------------------------------------------------

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

# --- UNUSED VARIABLES (Перенесены в vms_resources) ---
# variable "vm_db_cores" { ... }
# variable "vm_db_memory" { ... }
# variable "vm_db_core_fraction" { ... }
# variable "vm_db_disk_size" { ... }
# variable "vm_db_disk_type" { ... }
# --------------------------------------------------------

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
