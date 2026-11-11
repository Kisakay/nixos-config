{ pkgs, ... }:

{
  # Flameshot sous COSMIC (Wayland) : la capture passe par le portail
  # xdg-desktop-portal-cosmic (interface Screenshot), déjà activé dans
  # desktop/cosmic.nix. enableWlrSupport ajoute grim comme backend alternatif
  # (option "useGrimAdapter" dans flameshot.ini) si le portail pose problème.
  environment.systemPackages = [
    (pkgs.flameshot.override { enableWlrSupport = true; })
  ];
}
