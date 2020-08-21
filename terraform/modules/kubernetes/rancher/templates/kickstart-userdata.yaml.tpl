#cloud-config
users:
  - default #Define a default user
  - name: ubuntu
    gecos: ubuntu
    lock_passwd: false
    groups: sudo, users, admin
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ${ssh_public_key}
system_info:
  default_user:
    name: default-user
    lock_passwd: false
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
ssh_pwauth: yes #Use pwd to access (otherwise follow official doc to use ssh-keys)
random_seed:
  file: /dev/urandom
  command: ["pollinate", "-r", "-s", "https://entropy.ubuntu.com"]
  command_required: true
package_upgrade: true
write_files:
  - encoding: base64
    content: |
      network:
        version: 2
        ethernets:
          ens192:
            dhcp4: true
            nameservers:
              addresses: ["1.1.1.1", "8.8.8.8"]
    path: /etc/netplan/50-cloud-init.yaml
runcmd:
  - netplan apply
  - apt update && apt install python3-pip -y  # requirement for vmware guestinfo datasource installer, needs to be run after network is configured
  - curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh - 2>&1 | tee install.out #Install cloud-init
power_state:
  timeout: 300
  mode: reboot
