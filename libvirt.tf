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


resource "libvirt_network" "os-internal" {
  name      = "os-mgmt"
  mode      = "bridge"
  bridge    = "${var.ovs-datapath}"
  xml {
    xslt = "${data.template_file.network_xml_override.rendered}"
  }
}

data "template_file" "network_xml_override" {
  template = "${file("${path.module}/templates/ovs-network.xsl")}"
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
  size   = 53600000000
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
      default_user = var.default_user
  })
  network_config =   templatefile("${path.module}/templates/network_config.tpl", {
     interfaces = var.hosts[count.index].interfaces
     ips   = var.hosts[count.index].ips
     macs = var.hosts[count.index].macs
     vlans = var.hosts[count.index].vlans
     vlan_ips = var.hosts[count.index].vlan_ips
  })
}


resource "libvirt_domain" "domain-distro" {
  count  = "${length(var.hosts)}"
  name   = var.hosts[count.index].hostname
  memory = var.hosts[count.index].memory
  vcpu   = var.hosts[count.index].vcpu
  cloudinit = element(libvirt_cloudinit_disk.commoninit.*.id, count.index)
  
  network_interface {
      network_id   = libvirt_network.os-internal.id
      mac          = var.hosts[count.index].macs[0]
  }

  network_interface {
      network_id   = libvirt_network.os-external.id
      mac          = var.hosts[count.index].macs[1]
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


resource "null_resource" "network_switch_config" {
  count  = "${length(var.hosts)}"
  provisioner "local-exec" {
    command = "echo \"# $HOSTNAME \n$LOOKUP_CMD \n$OFPORT_CMD\" >> /tmp/switch_port_configurations.txt"
      environment = {
        LOOKUP_CMD = "IFACE=`ovs-vsctl --columns=name,external-ids -f csv list Interface | grep ${libvirt_domain.domain-distro[count.index ].id} | cut -d\",\" -f1`"
        OFPORT_CMD = "ovs-vsctl -- set Interface $IFACE ofport_request=${var.hosts[count.index].switch_port}"
        HOSTNAME = "${var.hosts[count.index].hostname}"
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo '' > /tmp/switch_port_configurations.txt"
  }
}