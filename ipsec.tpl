# strongSwan IPsec connection configuration file: 
# /etc/swanctl/conf.d/swanctl.conf
#
# strongSwan Daemon configuration file:
# /etc/strongswan.conf
policy_name: ${POLICY_NAME}
remote_ip: ${REMOTE_IP}
preshared_key: ${PRESHARED_KEY}
remote_subnets: ${REMOTE_SUBNETS}
# https://docs.strongswan.org/docs/latest/config/proposals.html
ike_proposal: ${IKE_PROPOSAL}
esp_proposal: ${ESP_PROPOSAL}
# https://docs.strongswan.org/docs/latest/config/retransmission.html
r_timeout: ${R_TIMEOUT}
r_tries: ${R_TRIES}
r_base: ${R_BASE}
