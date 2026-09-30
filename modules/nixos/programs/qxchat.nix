{ inputs, ... }:

{
  imports = [ "${inputs.qxchat-src}/nix/module.nix" ];

  nixpkgs.overlays = [
    # Workaround for webkitgtk 2.54.0 + enableExperimental=true (used by qxchat):
    # USE_VULKAN now defaults to ENABLE_EXPERIMENTAL_FEATURES, so configure
    # fails with "Volk is required for USE_VULKAN" because nixpkgs does not
    # add Zeux volk (vulkan-volk) to buildInputs. Remove once upstream fixes
    # pkgs/by-name/we/webkitgtk_6_0/package.nix.
    # Note: webkitgtk_4_1 is defined as `webkitgtk_6_0.override { gtk4 = gtk3; }`,
    # so fixing _6_0 is enough. Tested: overrideAttrs composes with qxchat.nix's
    # internal `webkitgtk_4_1.override { enableExperimental = true; }`.
    (final: prev: {
      webkitgtk_6_0 = prev.webkitgtk_6_0.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [
          prev.vulkan-headers
          prev.vulkan-volk
        ];
      });
    })
    (final: prev: {
      qxchat = final.callPackage "${inputs.qxchat-src}/nix/qxchat.nix" { };
    })
    inputs.tidaLuna.overlays.default
  ];

  programs.qxchat.enable = true;
}
