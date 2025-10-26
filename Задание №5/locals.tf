locals {
  # Формируем имя ВМ WEB, включая префикс, название и Folder ID
  vm_web_full_name = "${var.vm_web_name}-${var.subnet_zone}-${substr(var.folder_id, 0, 4)}"

  # Формируем имя ВМ DB, включая название и Zone
  vm_db_full_name = "${var.vm_db_name}-${var.vm_db_zone}"
}
