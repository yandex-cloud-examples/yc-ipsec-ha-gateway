# IPsec HA Gateway VM's configuration
sgw_vm_config = {
  name             = "ipsec-gw"
  folder_id        = "b1g4c..........2dqp5"
  image_family     = "ipsec-container-instance"
  vm_platform      = "standard-v3"
  vm_cores         = 2
  vm_memory        = 4
  vm_user_name     = "oper"
  vm_user_key_file = "~/.ssh/id_ed25519.pub"
  hc_port          = 8000
  net_name         = "ipsec-net"

  nodes = [
    {
      subnet_name   = "ipsec-net-subnet-1"
      zone_id       = "ru-central1-d"
      subnet_prefix = "10.10.11.0/24"
      ip            = "10.10.11.100"
      ip_rs_hc      = "10.10.11.101"
    },
    {
      subnet_name = "ipsec-net-subnet-2"
      zone_id       = "ru-central1-b"
      subnet_prefix = "10.10.12.0/24"
      ip            = "10.10.12.100"
      ip_rs_hc      = "10.10.12.101"
    },
  ]
}

# Routing to remote subnets via IPsec HA Gateway
remote_subnets = {
  net_name    = "ipsec-net"
  rt_name     = "ipsec-gw-rt"
  prefix_list = ["192.168.11.0/24", "192.168.12.0/24"]
}

# Remote IPsec Gateway configuration
remote_sgw = {
  name           = "Remote IPsec-GW"
  type           = "strongswan"
  outside_pub_ip = "public-ip-2"
}

# IPsec Connection parameters
ipsec_policy = {
  policy_name  = "yc-ipsec"
  ike_proposal = "aes128gcm16-prfsha256-ecp256"
  esp_proposal = "aes128gcm16"
  psk          = "Sup@385paS4"
  r_timeout      = "3.0"
  r_tries        = "3"
  r_base         = "1.0"
}

# Route-Switcher Active mode
rs_status = true
