variable "hosts" {
  type = list(object({
    hostname = string
    memory = number
    vcpu = number
    interfaces = list(string)
    ips = list(string)
    macs = list(string)
  }))
  default = [
    {
      hostname = "control01"
      memory = 4096
      vcpu = 2
      interfaces = ["eth0", "eth1", "eth2"]
      ips = ["10.10.0.10", "172.16.0.10", ""]
      macs = ["52:54:00:50:99:c5", "52:54:00:50:99:c6", "52:54:00:50:99:c7"]
    },
    {
      hostname = "compute01"
      memory = 4096
      vcpu = 2
      interfaces = ["eth0", "eth1", "eth2"]
      ips = ["10.10.0.11", "172.16.0.11", ""]
      macs = ["52:54:00:50:99:d5", "52:54:00:50:99:d6", "52:54:00:50:99:d7"]
    },
    {
      hostname = "network01"
      memory = 4096
      vcpu = 1
      interfaces = ["eth0", "eth1", "eth2"]
      ips = ["10.10.0.12", "172.16.0.12", ""]
      macs = ["52:54:00:50:99:e5", "52:54:00:50:99:e6", "52:54:00:50:99:e7"]
    }
  ]
}

variable "distros" {
  type = list
  default = ["focal-server-cloudimg-amd64"]
}