#cloud-config

datasource:
  Ec2:
    strict_id: false
ssh_pwauth: yes
users:
  - name: "${USER_NAME}"
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh-authorized-keys:
      - "${USER_SSH_KEY}"

runcmd:
  - sleep 1
  - sudo -i
  - /usr/local/bin/ipsec-init.sh
