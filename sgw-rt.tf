
# SGW VPC Network
data "yandex_vpc_network" "sgw_net" {
  folder_id = var.sgw_vm_config.folder_id
  name      = var.sgw_vm_config.net_name
}

# SGW 2x VPC Subnets (Primary & Secondary)
data "yandex_vpc_subnet" "sgw_subnet" {
  count     = length(var.sgw_vm_config.nodes)
  folder_id = var.sgw_vm_config.folder_id
  name      = var.sgw_vm_config.nodes["${count.index}"].subnet_name
}

# Route table for route traffic to remote subnets via SGW
resource "yandex_vpc_route_table" "sgw_rt" {
  folder_id  = var.sgw_vm_config.folder_id
  name       = var.remote_subnets.rt_name
  network_id = data.yandex_vpc_network.sgw_net.id

  dynamic "static_route" {
    for_each = var.remote_subnets == null ? [] : var.remote_subnets.prefix_list
    content {
      destination_prefix = static_route.value
      next_hop_address   = var.sgw_vm_config.nodes[0].ip
    }
  }
}
