{ pkgs ? import <nixpkgs> { } }:
let myTerraform = pkgs.terraform_0_15.withPlugins (tp: [ tp.libvirt ]);
in
pkgs.mkShell {
  buildInputs = [ myTerraform ];
}
