{ config, pkgs, ... }:

{
  services.flatpak.enable = true;

  services.flatpak.remotes = [
    {
      name = "flathub-beta";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];


  # services.flatpak.packages = [
  #   "flathub:com.github.flxzt.rnote"
  # ];

}
