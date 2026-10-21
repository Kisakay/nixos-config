# Modules issus des inputs du flake : QxChat, Zen Browser et Nightcord.
{ inputs, pkgs, ... }:

let
  # Le paquet « nightcord » du flake amont utilise nodejs_20 (EOL, retiré de
  # nixpkgs) et n'installe jamais les dépendances pnpm : on reconstruit le cœur
  # du mod contre notre nixpkgs, puis on enveloppe Discord nous-mêmes.
  nightcordVersion =
    (builtins.fromJSON (builtins.readFile "${inputs.nightcord}/package.json")).version;

  nightcordCore = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "nightcord";
    version = nightcordVersion;

    src = inputs.nightcord;

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pkgs.pnpm_10;
      fetcherVersion = 4;
      hash = "sha256-Ta84vdQEcxDm7tKiiT25+GPyGijATFP5uoSjNDodLZs=";
    };

    nativeBuildInputs = [
      pkgs.nodejs
      pkgs.pnpm_10
      pkgs.pnpmConfigHook
      pkgs.git
    ];

    env = {
      NIGHTCORD_REMOTE = "nightcord/nightcord";
      NIGHTCORD_HASH = inputs.nightcord.rev or "unknown";
      SOURCE_DATE_EPOCH = builtins.toString (inputs.nightcord.lastModified or 0);
    };

    buildPhase = ''
      runHook preBuild
      pnpm run build -- --standalone --disable-updater
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/nightcord
      cp -r dist/desktop/* $out/share/nightcord/
      runHook postInstall
    '';

    meta = {
      description = "Discord client mod (Nightcord)";
      homepage = "https://nightcord.st";
      license = pkgs.lib.licenses.gpl3Plus;
      platforms = pkgs.lib.platforms.linux;
    };
  });

  # Injection façon nixpkgs (cf. pkgs/by-name/di/discord : avecVencord) :
  # on remplace app.asar par un dossier qui charge le patcher Nightcord.
  # Le « discord » de nixpkgs est aujourd'hui un wrapper FHS : les vrais
  # fichiers sont dans unwrappedDiscord, pas dans pkgs.discord directement.
  discord-nightcord = pkgs.discord.override {
    unwrappedDiscord = pkgs.discord.unwrappedDiscord.overrideAttrs (old: {
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
  imports = [ "${inputs.qxchat-src}/nix/module.nix" ];

  nixpkgs.overlays = [
    (final: prev: {
      qxchat = prev.callPackage "${inputs.qxchat-src}/nix/qxchat.nix" { };
    })
  ];

  programs.qxchat.enable = true;

  environment.systemPackages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.nightcord = {
    enable = true;
    package = discord-nightcord;
  };
}
