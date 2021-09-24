terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.9-pre3"
    }
  }
}



# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "ubuntu" {
  name = "ubuntu"
  type = "dir"
  path = "${path.module}/volumes"
}


resource "libvirt_network" "os-mgmt" {
  name      = "os-mgmt"
  domain    = "os-mgmt.local"
  mode      = "nat"
  addresses = ["10.10.0.0/24"]
}

resource "libvirt_network" "os-lbaas" {
  name      = "os-lbaas"
  domain    = "os-lbaas.local"
  mode      = "nat"
  addresses = ["172.16.0.0/24"]
}

resource "libvirt_network" "os-external" {
  name      = "os-external"
  domain    = "os-external.local"
  mode      = "nat"
  addresses = ["192.168.121.0/24"]
}



resource "libvirt_volume" "cinder-qcow2" {
  name   = "cinder.qcow2"
  pool   = libvirt_pool.ubuntu.name
  format = "qcow2"
  size   = 53687091200
}


resource "libvirt_volume" "distro-qcow2" {
  count  = "${length(var.hosts)}"
  name   = "${var.hosts[count.index].hostname}.qcow2"
  pool   = libvirt_pool.ubuntu.name
  source = "${path.module}/sources/${var.distros[0]}.qcow2"
  format = "qcow2"
}



resource "libvirt_cloudinit_disk" "commoninit" { 
  count     = "${length(var.hosts)}"
  name      = "commoninit-${var.hosts[count.index].hostname}.iso"
  pool      = libvirt_pool.ubuntu.name
  user_data = templatefile("${path.module}/templates/user_data.tpl", {
      host_name = var.hosts[count.index].hostname
      auth_key  = file("${path.module}/ssh/id_rsa.pub")
  })
  network_config =   templatefile("${path.module}/templates/network_config.tpl", {
     interfaces = var.hosts[count.index].interfaces
     ips   = var.hosts[count.index].ips
     macs = var.hosts[count.index].macs
  })
}


resource "libvirt_domain" "domain-distro" {
  count  = "${length(var.hosts)}"
  name   = var.hosts[count.index].hostname
  memory = var.hosts[count.index].memory
  vcpu   = var.hosts[count.index].vcpu
  cloudinit = element(libvirt_cloudinit_disk.commoninit.*.id, count.index)
  
  network_interface {
      network_name = "os-mgmt"
      mac          = var.hosts[count.index].macs[0]
  }

  network_interface {
      network_name = "os-lbaas"
      mac          = var.hosts[count.index].macs[1]
  }

  network_interface {
      network_name = "os-external"
      mac          = var.hosts[count.index].macs[2]
  }
  console {
      type        = "pty"
      target_port = "0"
      target_type = "serial"
  }
  console {
      type        = "pty"
      target_port = "1"
      target_type = "virtio"
  }
  disk {
      volume_id = element(libvirt_volume.distro-qcow2.*.id, count.index)
  }

  dynamic "disk" {
    for_each = var.hosts[count.index].hostname == "compute01" ? toset([1]) : toset([])
    content {
      volume_id = element(libvirt_volume.cinder-qcow2.*.id, count.index)
    }
  }

}
