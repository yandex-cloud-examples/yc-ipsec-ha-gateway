# ===============================
# Network Load Balancer resources
# ===============================

# Reserve a static IP for the SGW instance
resource "yandex_vpc_address" "sgw_public_ip" {
  folder_id = var.sgw_vm_config.folder_id
  name      = lower(var.sgw_vm_config.name)
  external_ipv4_address {
    zone_id = var.sgw_vm_config.nodes[0].zone_id
  }
}

resource "yandex_lb_target_group" "sgw_tg" {
  folder_id = var.sgw_vm_config.folder_id
  name      = "${lower(var.sgw_vm_config.name)}-tg"
  //region_id = "ru-central1"

  dynamic "target" {
    for_each = range(length(var.sgw_vm_config.nodes))
    content {
      address   = var.sgw_vm_config.nodes[target.value].ip
      subnet_id = data.yandex_vpc_subnet.sgw_subnet[target.value].id
    }
  }
}

resource "yandex_lb_network_load_balancer" "sgw_nlb" {
  name      = "${lower(var.sgw_vm_config.name)}-nlb"
  folder_id = var.sgw_vm_config.folder_id
  type      = "external"

  listener {
    name     = "udp-4500"
    protocol = "udp"
    port     = 4500
    external_address_spec {
      address    = yandex_vpc_address.sgw_public_ip.external_ipv4_address[0].address
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.sgw_tg.id

    healthcheck {
      name                = "tcp-${var.sgw_vm_config.hc_port}"
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 2
      tcp_options {
        port = var.sgw_vm_config.hc_port
      }
    }
  }
}

output "sgw-public-ip" {
  value = yandex_vpc_address.sgw_public_ip.external_ipv4_address[0].address
}
