
module "route_switcher" {
  source                      = "github.com/yandex-cloud-examples/yc-route-switcher"
  start_module                = var.rs_status
  folder_id                   = var.sgw_vm_config.folder_id
  route_table_folder_list     = [var.sgw_vm_config.folder_id]
  route_table_list            = [yandex_vpc_route_table.sgw_rt.id]
  security_group_folder_list  = [var.sgw_vm_config.folder_id]
  router_healthcheck_port     = var.sgw_vm_config.hc_port
  back_to_primary             = true
  router_healthcheck_interval = 10
  routers = [
    // Definition of primary node -> secondary node switchover
    {
      healthchecked_ip        = var.sgw_vm_config.nodes[0].ip_rs_hc
      healthchecked_subnet_id = data.yandex_vpc_subnet.sgw_subnet[0].id
      primary                 = true
      vm_id                   = yandex_compute_instance.sgw_vm[0].id
      interfaces = [
        {
          own_ip             = var.sgw_vm_config.nodes[0].ip
          backup_peer_ip     = var.sgw_vm_config.nodes[1].ip
          index              = 0
          security_group_ids = [yandex_vpc_security_group.sgw_pri_sg.id]
        }
      ]
    },
    // Definition of secondary node -> primary node switchover
    {
      healthchecked_ip        = var.sgw_vm_config.nodes[1].ip_rs_hc
      healthchecked_subnet_id = data.yandex_vpc_subnet.sgw_subnet[1].id
      vm_id                   = yandex_compute_instance.sgw_vm[1].id
      interfaces = [
        {
          own_ip             = var.sgw_vm_config.nodes[1].ip
          backup_peer_ip     = var.sgw_vm_config.nodes[0].ip
          index              = 0
          security_group_ids = [yandex_vpc_security_group.sgw_sec_sg.id]
        }
      ]
    }
  ]
}
