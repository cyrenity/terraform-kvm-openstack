variable "hosts" {
  type = list(object({
    hostname = string
    memory = number
    vcpu = number
    interfaces = list(string)
    ips = list(string)
    vlan_ips = list(string)
    vlans = list(string)
    macs = list(string)
    switch_port = number
  }))
  default = [
    {
      hostname = "control01"
      memory = 4096
      vcpu = 2
      interfaces = ["eth0", "eth1"]
      ips = ["192.168.0.10", ""]
      macs = ["52:54:00:50:99:c5", "52:54:00:50:99:c6"]
      vlans = ["200", "300"]
      vlan_ips = ["10.0.0.10", "172.16.0.10"]
      switch_port = 1
    },
    {
      hostname = "compute01"
      memory = 4096
      vcpu = 2
      interfaces = ["eth0", "eth1"]
      ips = ["10.10.0.11", ""]
      macs = ["52:54:00:50:99:d5", "52:54:00:50:99:d6"]
      vlans = ["200", "300"]
      vlan_ips = ["10.0.0.11", "172.16.0.11"]
      switch_port = 2

    },
    {
      hostname = "network01"
      memory = 4096
      vcpu = 1
      interfaces = ["eth0", "eth1"]
      ips = ["10.10.0.12", ""]
      macs = ["52:54:00:50:99:e5", "52:54:00:50:99:e6"]
      vlans = ["200", "300"]
      vlan_ips = ["10.0.0.12", "172.16.0.12"]
      switch_port = 3
    }
  ]
}

variable "distros" {
  type = list
  default = ["focal-server-cloudimg-amd64"]
}