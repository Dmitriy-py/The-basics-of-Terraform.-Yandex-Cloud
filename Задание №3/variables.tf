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
  description = "Zone for the WEB VM and shared subnet (default ru-central1-a)"
  type        = string
  default     = "ru-central1-a"
}

variable "vms_ssh_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
}

# --- Network & SG Variables ---

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
