
# ============================================
# Security Group for Active SGW instance (PRI)
# ============================================
resource "yandex_vpc_security_group" "sgw_pri_sg" {
  folder_id   = var.sgw_vm_config.folder_id
  name        = "${lower(var.sgw_vm_config.name)}-pri-sg"
  description = "Active SGW SG"
  network_id  = data.yandex_vpc_network.sgw_net.id

  ingress {
    description    = "icmp"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ssh"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ipsec"
    protocol       = "UDP"
    port           = "4500"
    v4_cidr_blocks = ["${var.remote_sgw.outside_pub_ip}/32"]
    #v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Health checks from NLB"
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# =============================================
# Security Group for Standby SGW instance (SEC)
# =============================================
resource "yandex_vpc_security_group" "sgw_sec_sg" {
  folder_id   = var.sgw_vm_config.folder_id
  name        = "${lower(var.sgw_vm_config.name)}-sec-sg"
  description = "Standby SGW SG"
  network_id  = data.yandex_vpc_network.sgw_net.id

  ingress {
    description    = "icmp"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "ssh"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================================
# Security Group for Route-Switcher HC interface
# ==============================================
resource "yandex_vpc_security_group" "sgw_rs_sg" {
  folder_id   = var.sgw_vm_config.folder_id
  name        = "${lower(var.sgw_vm_config.name)}-rs-sg"
  description = "RouteSwitcher HC SG"
  network_id  = data.yandex_vpc_network.sgw_net.id

  ingress {
    description    = "icmp"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Health checks from NLB"
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
