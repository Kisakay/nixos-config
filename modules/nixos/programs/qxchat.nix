{ inputs, ... }:

{
  imports = [ "${inputs.qxchat-src}/nix/module.nix" ];

  nixpkgs.overlays = [
    (final: prev: {
      qxchat = final.callPackage "${inputs.qxchat-src}/nix/qxchat.nix" { };
    })
  ];

  programs.qxchat.enable = true;
}
