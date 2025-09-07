# ==================================================================
# IPsec configuration file builder for the selected remote SGW type.
# ==================================================================

# Create Remote site IPsec gateway configuration
locals {

  local_subnets = flatten([for el in range(length(var.sgw_vm_config.nodes)) : [
    var.sgw_vm_config.nodes[el].subnet_prefix]
  ])

  subnets_pairs = flatten([
    for key in local.local_subnets : [
      for val in var.remote_subnets.prefix_list : {
        yc     = key
        remote = val
      }
    ]
  ])

  remote_ipsec_config = templatefile("${path.module}/ipsec-templates/${var.remote_sgw.type}.tpl", {
    SGW_NAME          = var.remote_sgw.name
    YC_SGW_IP         = "${yandex_vpc_address.sgw_public_ip.external_ipv4_address[0].address}"
    REMOTE_SGW_PUB_IP = var.remote_sgw.outside_pub_ip
    POLICY_NAME       = var.ipsec_policy.policy_name
    IKE_PROPOSAL      = var.ipsec_policy.ike_proposal
    ESP_PROPOSAL      = var.ipsec_policy.esp_proposal
    PSK               = var.ipsec_policy.psk
    LOCAL_SUBNETS     = join(",", var.remote_subnets.prefix_list)
    # For remote SGW's which are supported the Routed mode (IPsec Tunnel interface)
    YC_SUBNETS = local.local_subnets
    # For remote SGW's which are NOT SUPPORTED the Routed mode, e.g. Mikrotik
    SUBNETS_PAIRS = local.subnets_pairs
    # YC Subnets string notation for the Strongswan
    YC_SUBNETS_STR = join(",", local.local_subnets)
  })
}

resource "local_file" "remote_ipsec_config" {
  content         = local.remote_ipsec_config
  filename        = "ipsec-config.txt"
  file_permission = "644"

  lifecycle {
    ignore_changes = [content]
  }
}
