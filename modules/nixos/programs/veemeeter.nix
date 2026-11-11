{ inputs, ... }:

{
  # VeeMeeter : table de mixage PipeWire (remplaçant de PulseMeeter).
  # Paquet + service utilisateur lancé avec PipeWire à chaque session.
  imports = [ inputs.veemeeter.nixosModules.default ];

  programs.veemeeter.enable = true;
}
