{ pkgs ? import (import ./nixpkgs.nix) { }, lib ? pkgs.lib }:
let config = { config, lib, modulesPath, pkgs, ... }:
  {
    imports = [
      "${toString modulesPath}/profiles/qemu-guest.nix"
    ];

    config = {
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
        autoResize = true;
      };

      boot.growPartition = true;
      boot.kernelParams = [ "console=ttyS0" ];
      boot.loader.grub.device = "/dev/vda";
      boot.loader.timeout = 0;

      networking.firewall.allowedTCPPorts = [ 22 ];
      services.openssh = {
        enable = true;
        permitRootLogin = "yes";
        extraConfig = ''
          PermitEmptyPasswords yes
        '';
      };

      users.users.root.password = "";

      system.build.qcow = import "${toString modulesPath}/../lib/make-disk-image.nix" {
        inherit config lib pkgs;
        diskSize = 8192;
        format = "qcow2";
      };
    };
  };
in
(pkgs.nixos config).qcow
