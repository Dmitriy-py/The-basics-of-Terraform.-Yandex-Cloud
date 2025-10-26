output "vms_details" {
  description = "Detailed information for all created VMs (name, IP, FQDN)"
  value = {
    vm_web = {
      instance_name = yandex_compute_instance.vm_web.name
      external_ip   = yandex_compute_instance.vm_web.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.vm_web.fqdn
    }
    vm_db = {
      instance_name = yandex_compute_instance.vm_db.name
      external_ip   = yandex_compute_instance.vm_db.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.vm_db.fqdn
    }
  }
}
