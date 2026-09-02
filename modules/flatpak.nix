{ config, pkgs, ... }:

{
services.flatpak.enable = true;

services.flatpak.remotes = [{
  name = "flathub-beta"; location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
}];

services.flatpak.packages = [
  "com.github.flxzt.rnote"
];
}
