# ==================================================================
# strongSwan YC image:
# https://yandex.cloud/marketplace/products/yc/ipsec-instance-ubuntu
#
# strongSwan configuration file for ${SGW_NAME} @ Yandex Cloud
# /etc/swanctl/swanctl.conf
# 
# strongSwan configuration docs:
# https://docs.strongswan.org/docs/latest/swanctl/swanctlConf.html
# ==================================================================

connections {
  ${POLICY_NAME} {
    local_addrs = ${REMOTE_SGW_PUB_IP}
    remote_addrs = ${YC_SGW_IP}
    local {
      auth = psk
    }
    remote {
      auth = psk
    }
    version = 2 # IKEv2
    mobike = no
    proposals = ${IKE_PROPOSAL}, default
    dpd_delay = 10s
    children {
      ${POLICY_NAME} {
        # Local IPv4 subnets
        local_ts = ${LOCAL_SUBNETS}

        # Remote IPv4 subnets
        remote_ts = ${YC_SUBNETS_STR}

        start_action = start
        esp_proposals = ${ESP_PROPOSAL}
        dpd_action = restart
      }
    }
  }
}

# Pre-Shared Key (PSK) for IPsec connection
secrets {
  ike-${POLICY_NAME} {
    id = %any
    secret = ${PSK}
  }
}
