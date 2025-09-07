
# ===================================
# IPsec HA Gateway VM's configuration
# ===================================
variable "sgw_vm_config" {
  description = "IPsec HA Gateway VM's configuration."
  type = object(
    {
      name         = string
      folder_id    = string
      image_family = string

      vm_platform = string
      vm_cores    = number
      vm_memory   = number

      vm_user_name     = string
      vm_user_key_file = string
      hc_port          = number
      net_name         = string

      nodes = list(object(
        {
          subnet_name   = string
          zone_id       = string
          subnet_prefix = string
          ip            = string
          ip_rs_hc      = string
        }
      ))
  })
  default = {
    name         = null
    folder_id    = null
    image_family = null

    vm_platform = "standard-v3"
    vm_cores    = 2
    vm_memory   = 4

    vm_user_name     = null
    vm_user_key_file = null
    hc_port          = 8000
    net_name         = null

    nodes = [
      {
        subnet_name   = null
        zone_id       = null
        subnet_prefix = null
        ip            = null
        ip_rs_hc      = null
      },
      {
        subnet_name   = null
        zone_id       = null
        subnet_prefix = null
        ip            = null
        ip_rs_hc      = null
      },
    ]
  }
}

# ===============================
# Remote IPsec Gateway route List
# ===============================
variable "remote_subnets" {
  description = "Remote IP prefixes (routes) list."
  type = object(
    {
      net_name    = string
      prefix_list = list(string)
      rt_name     = string
  })
  default = {
    net_name    = null
    prefix_list = null
    rt_name     = null
  }
}

# ===================================
# Remote IPsec Gateway configuration
# ===================================
variable "remote_sgw" {
  description = "Remote SGW Parameters"
  type = object(
    {
      name           = string
      type           = string
      outside_pub_ip = string
      #outside_ip     = string
  })
  default = {
    name           = null
    type           = "strongswan"
    outside_pub_ip = null
    #outside_ip     = null
  }
  validation {
    condition = contains([
      "iosxe",      # Cisco IOS-XE
      "asa",        # Cisco ASA
      "mikrotik",   # Mikrotik CHR
      "strongswan", # strongSwan
      ], lower(var.remote_sgw.type)
    )
    error_message = "Only few SGW types are supported. See variables.tf for details."
  }
}

# ===========================
# IPsec Connection parameters
# ===========================
variable "ipsec_policy" {
  description = "IPsec Connection parameters."
  type = object(
    {
      policy_name  = string
      ike_proposal = string
      esp_proposal = string
      psk          = string
      r_timeout    = string
      r_tries      = string
      r_base       = string
  })
  default = {
    policy_name  = "yc-ipsec"
    ike_proposal = "aes128gcm16-prfsha256-ecp256"
    esp_proposal = "aes128gcm16"
    psk          = null
    r_timeout    = "3.0"
    r_tries      = "3"
    r_base       = "1.0"
  }
}

variable "rs_status" {
  description = "Route Switcher module Active mode."
  type        = bool
  default     = false
}
