let
  System = import ../../hosts/computer/username.nix;
in
{
  users.users.${System.Username} = {
    isNormalUser = true;
    description = System.Fullname;
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
