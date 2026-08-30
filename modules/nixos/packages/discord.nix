{ pkgs, ... }:

let
  discordSettings = pkgs.writeText "discord-settings.json" ''
    {
      "SKIP_HOST_UPDATE": true
    }
  '';

  System = import ../../../hosts/computer/username.nix;
in
{
  environment.systemPackages = with pkgs; [
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
  ];

  system.activationScripts.discordSettings.text = ''
    install -d -o ${System.Username} -g users /home/${System.Username}/.config/discord

    if [ ! -e /home/${System.Username}/.config/discord/settings.json ]; then
      install -o ${System.Username} -g users \
        ${discordSettings} \
        /home/${System.Username}/.config/discord/settings.json
    fi
  '';
}
