{ inputs, ... }:

{
  imports = [ "${inputs.qxchat-src}/nix/module.nix" ];

  nixpkgs.overlays = [
    (final: prev: {
      qxchat = final.callPackage "${inputs.qxchat-src}/nix/qxchat.nix" { };
    })
    inputs.tidaLuna.overlays.default
  ];

  programs.qxchat.enable = true;
}
