#cloud-config

# vim: syntax=yaml
#
# ***********************
# 	---- for more examples look at: ------
# ---> https://cloudinit.readthedocs.io/en/latest/topics/examples.html
# ******************************
#
# This is the configuration syntax that the write_files module
# will know how to understand. encoding can be given b64 or gzip or (gz+b64).
# The content will be decoded accordingly and then written to the path that is
# provided.
#
# Note: Content strings here are truncated for example purposes.
hostname: ${host_name}
manage_etc_hosts: true
users:
  - name: ${default_user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${auth_key}
disable_root: false
ssh_pwauth: True
chpasswd:
  list: |
     root:emergen
     mustafa:emergen
  expire: False
%{ if host_name == "compute01" }
bootcmd:
  - pvcreate /dev/vdb
  - vgcreate cinder-volumes /dev/vdb
%{ endif }