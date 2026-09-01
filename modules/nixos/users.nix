let
  System = import ../../hosts/computer/username.nix;
in
{
  users.users.${System.Username} = {
    isNormalUser = true;
    description = System.Fullname;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAN4jjXCrvgOwttSLKl6uRFbWMolKWNSfZ4Dxa/QZDuO kisa@framework"
    ];
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "video"
      "render"
      "plugdev"
      "docker"
    ];
  };
}
