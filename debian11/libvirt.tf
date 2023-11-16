terraform {
 required_version = ">= 1"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      # version = "= 0.6.10"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# variables that can be overriden
variable "hostname" {
  type    = list(string)
  default = ["debian-1"]
}

variable "domain" {
default = "local"
}

variable "memoryMB" {
default = 1024*2 
}
variable "cpu" {
default = 1
}


# fetch Debian release
resource "libvirt_volume" "os_image" {
  count = length(var.hostname)
  name = "os_image.${var.hostname[count.index]}.qcow2"
  pool = "default"
  source = "http://cloud.debian.org/images/cloud/bullseye/20220911-1135/debian-11-genericcloud-amd64-20220911-1135.qcow2"
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
resource "libvirt_domain" "debian11-cloudinit" {
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

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

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
}

# Output Server IP
output "ips" {
  value = libvirt_domain.debian11-cloudinit.*.network_interface.0.addresses
}
