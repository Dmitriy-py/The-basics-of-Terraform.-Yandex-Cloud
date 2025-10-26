locals {
  vm_web_full_name = "${var.vm_web_name}-${var.subnet_zone}-${substr(var.folder_id, 0, 4)}"
  vm_db_full_name = "${var.vm_db_name}-${var.vm_db_zone}"
}
