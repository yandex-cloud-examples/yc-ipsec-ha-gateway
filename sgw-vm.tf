# =================
# Compute Resources
# =================

# Get VM image Id for SGW deployment
data "yandex_compute_image" "sgw_image" {
  family = var.sgw_vm_config.image_family
}

# =====================
# IPsec HA Gateway VM's
# =====================

resource "yandex_compute_instance" "sgw_vm" {
  count     = length(var.sgw_vm_config.nodes)
  folder_id = var.sgw_vm_config.folder_id

  name        = "${var.sgw_vm_config.name}-${substr(var.sgw_vm_config.nodes["${count.index}"].zone_id, -1, 1)}"
  hostname    = "${var.sgw_vm_config.name}-${substr(var.sgw_vm_config.nodes["${count.index}"].zone_id, -1, 1)}"
  platform_id = var.sgw_vm_config.vm_platform
  zone        = var.sgw_vm_config.nodes["${count.index}"].zone_id
  resources {
    cores  = var.sgw_vm_config.vm_cores
    memory = var.sgw_vm_config.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.sgw_image.id
    }
  }

  // Main (IPsec) interface
  network_interface {
    subnet_id          = data.yandex_vpc_subnet.sgw_subnet["${count.index}"].id
    ip_address         = var.sgw_vm_config.nodes["${count.index}"].ip
    nat                = false
    security_group_ids = count.index == 0 ? [yandex_vpc_security_group.sgw_pri_sg.id] : [yandex_vpc_security_group.sgw_sec_sg.id]
  }

  // Route-Switcher health check interface
  network_interface {
    subnet_id          = data.yandex_vpc_subnet.sgw_subnet["${count.index}"].id
    ip_address         = var.sgw_vm_config.nodes["${count.index}"].ip_rs_hc
    nat                = false
    security_group_ids = [yandex_vpc_security_group.sgw_rs_sg.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/vm-init.tpl", {
      USER_NAME    = var.sgw_vm_config.vm_user_name
      USER_SSH_KEY = file(var.sgw_vm_config.vm_user_key_file)
    }),
    ipsec = templatefile("${path.module}/ipsec.tpl", {
      POLICY_NAME    = var.ipsec_policy.policy_name
      REMOTE_IP      = var.remote_sgw.outside_pub_ip
      LOCAL_SGW_IP   = var.sgw_vm_config.nodes["${count.index}"].ip
      IKE_PROPOSAL   = var.ipsec_policy.ike_proposal
      ESP_PROPOSAL   = var.ipsec_policy.esp_proposal
      PRESHARED_KEY  = var.ipsec_policy.psk
      REMOTE_SUBNETS = replace(join(",", flatten(var.remote_subnets.prefix_list)), " ", "")
      R_TIMEOUT      = var.ipsec_policy.r_timeout
      R_TRIES        = var.ipsec_policy.r_tries
      R_BASE         = var.ipsec_policy.r_base
    })
  }
}
