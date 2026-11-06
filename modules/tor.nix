{ pkgs, ... }:

{
  services.tor = {
    enable = true;
    client.dns.enable = true;

    settings = {
      UseBridges = true;
      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
      Bridge = "obfs4 IP:ORPort [fingerprint]";
    };
  };

  environment.systemPackages = with pkgs; [
    tor-browser
  ];
}
