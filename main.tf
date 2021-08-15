terraform {
  required_providers {
    libvirt = {
      source = "nixpkgs/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
