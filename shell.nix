{ pkgs ? import (import ./nixpkgs.nix) { } }:
let
  makeImage = pkgs.writeShellScriptBin "make-image" ''
    nix-build image.nix -o image
  '';
  myTerraform = pkgs.terraform_0_15.withPlugins (tp: [ tp.libvirt ]);
in
pkgs.mkShell {
  buildInputs = [ makeImage myTerraform ];
}
