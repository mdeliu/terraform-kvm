terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}
provider "libvirt" {
  uri = "qemu:///system"
}

# variables that can be overriden
variable "hostname" {
  type    = list(string)
  default = ["debianvm"] # can be extended as needed
}

variable "domain" {
  default = "local"
}

variable "memoryMB" {
  default = 2048
}
variable "cpu" {
  default = 2
}


# Fetch Debian
resource "libvirt_volume" "os_image" {
  count = length(var.hostname)
  name = "os_image.${var.hostname[count.index]}.qcow2"
  pool = "default"
  source = "debian-12-genericcloud-amd64.qcow2"
  format = "qcow2"
}


# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  count = length(var.hostname)
  name = "${var.hostname[count.index]}-commoninit.iso"
  user_data = templatefile("${path.module}/cloud_init.cfg", 
                          { hostname = element(var.hostname, count.index), fqdn = "${var.hostname[count.index]}.${var.domain}" })
}

# Create the machine
resource "libvirt_domain" "debian12-cloudinit" {
  count = length(var.hostname)
  name = "${var.hostname[count.index]}"
  memory = var.memoryMB
  vcpu = var.cpu

 disk {
    volume_id = element(libvirt_volume.os_image.*.id, count.index)
  }
  
  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }

  xml {
    xslt = file("input.xsl")
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id


}


# Output Server IP
output "ips" {
  value = libvirt_domain.debian12-cloudinit.*.network_interface.0.addresses
}
