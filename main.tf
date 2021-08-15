terraform {
  required_providers {
    libvirt = {
      source = "nixpkgs/libvirt"
    }
  }
}

locals {
  GIG = 1024 * 1024 * 1024
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "boot" {
  name   = "nixos_boot"
  source = "image/nixos.qcow2"
}

resource "libvirt_volume" "data" {
  count = 6
  name  = "data${count.index + 1}"
  size  = 2 * local.GIG
}

resource "libvirt_domain" "raidy" {
  name    = "raidy"
  memory  = 2048
  cmdline = []

  disk {
    volume_id = libvirt_volume.boot.id
  }

  dynamic "disk" {
    for_each = libvirt_volume.data
    content {
      volume_id = disk.value.id
    }
  }

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }
}
