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
  disk = concat(
    [{
      volume_id = libvirt_volume.boot.id

      // https://github.com/dmacvicar/terraform-provider-libvirt/issues/728
      block_device = null, file = null, scsi = null, url = null, wwn = null,
    }],
    [for vol in libvirt_volume.data : {
      volume_id = vol.id

      // https://github.com/dmacvicar/terraform-provider-libvirt/issues/728
      block_device = null, file = null, scsi = null, url = null, wwn = null, // ?
    }],
  )
  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }
}
