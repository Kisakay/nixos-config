{ inputs, pkgs, ... }:

let
  discordSettings = pkgs.writeText "discord-settings.json" ''
    {
      "SKIP_HOST_UPDATE": true
    }
  '';

  System = import ../../../hosts/computer/username.nix;

  # Nightcord core, built against our own nixpkgs (not the flake's pinned one).
  nightcordCore = pkgs.callPackage "${inputs.nightcord}/default.nix" {
    src = inputs.nightcord;
    gitHash = inputs.nightcord.rev or "unknown";
  };

  # Nightcord injection: app.asar becomes a folder that loads the Nightcord
  # patcher, which then loads the original Discord (_app.asar). The nixpkgs
  # "discord" is an FHS wrapper, so the patch goes on unwrappedDiscord.
  discordBase = pkgs.discord.override {
    withTTS = false;
  };

  discord-nightcord = discordBase.override {
    unwrappedDiscord = discordBase.unwrappedDiscord.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          mv $out/opt/Discord/resources/app.asar $out/opt/Discord/resources/_app.asar
          mkdir $out/opt/Discord/resources/app.asar
          echo '{"name":"discord","main":"index.js"}' > $out/opt/Discord/resources/app.asar/package.json
          echo 'require("${nightcordCore}/share/nightcord/patcher.js")' > $out/opt/Discord/resources/app.asar/index.js
        '';
    });
  };
in
{
  imports = [ inputs.nightcord.nixosModules.default ];

  programs.nightcord = {
    enable = true;
    package = discord-nightcord;
  };

  environment.systemPackages = with pkgs; [
    discord-canary
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
