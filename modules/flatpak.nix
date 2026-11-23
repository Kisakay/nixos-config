{ config, pkgs, ... }:

let
  # Flatpak réécrit les .desktop exportés et supprime les clés X-* dont
  # COSMIC a besoin (X-CosmicApplet, X-HostWaylandDisplay, ...). Sans elles,
  # cosmic-panel / cosmic-settings ne voient pas les applets installées
  # via Flatpak. Ce script recopie les clés X-* manquantes depuis le .desktop
  # d'origine (files/share/applications) vers le .desktop exporté.
  flatpak-cosmic-applet-fix = pkgs.writeShellApplication {
    name = "flatpak-cosmic-applet-fix";
    runtimeInputs = with pkgs; [ coreutils gawk gnugrep ];
    text = ''
      root="''${1:?usage: flatpak-cosmic-applet-fix <flatpak installation dir>}"
      shopt -s nullglob
      for exp in "$root"/app/*/current/active/export/share/applications/*.desktop; do
        active="''${exp%/export/share/applications/*}"
        src="$active/files/share/applications/$(basename "$exp")"
        [ -f "$src" ] || continue
        grep -q '^X-CosmicApplet=' "$src" || continue

        # Clés X-* du groupe [Desktop Entry] d'origine absentes de l'export.
        missing="$(awk '
          NR==FNR { if (/^\[/) g=$0; else if (g=="[Desktop Entry]" && /^X-[A-Za-z0-9-]+=/) { split($0,a,"="); have[a[1]]=1 } next }
          /^\[/ { g=$0; next }
          g=="[Desktop Entry]" && /^X-[A-Za-z0-9-]+=/ { split($0,a,"="); if (!(a[1] in have)) print }
        ' "$exp" "$src")"
        [ -n "$missing" ] || continue

        tmp="$(mktemp "$exp.XXXXXX")"
        awk -v add="$missing" '
          /^\[/ { if (g=="[Desktop Entry]") { print add; done=1 } g=$0 }
          { print }
          END { if (!done && g=="[Desktop Entry]") print add }
        ' "$exp" > "$tmp"
        chmod --reference="$exp" "$tmp"
        mv -f "$tmp" "$exp"
        echo "patched: $exp"
      done
    '';
  };
in
{
  services.flatpak.enable = true;

  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  # services.flatpak.packages = [
  #   "flathub:com.github.flxzt.rnote"
  # ];

  environment.systemPackages = [ flatpak-cosmic-applet-fix ];

  # Installations système (/var/lib/flatpak).
  systemd.services.flatpak-cosmic-applet-fix = {
    description = "Restore COSMIC applet keys in exported Flatpak desktop files (system)";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${flatpak-cosmic-applet-fix}/bin/flatpak-cosmic-applet-fix /var/lib/flatpak";
    };
  };
  systemd.paths.flatpak-cosmic-applet-fix = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = "/var/lib/flatpak/exports/share/applications";
  };

  # Installations utilisateur (~/.local/share/flatpak).
  systemd.user.services.flatpak-cosmic-applet-fix = {
    description = "Restore COSMIC applet keys in exported Flatpak desktop files (user)";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${flatpak-cosmic-applet-fix}/bin/flatpak-cosmic-applet-fix %h/.local/share/flatpak";
    };
  };
  systemd.user.paths.flatpak-cosmic-applet-fix = {
    wantedBy = [ "default.target" ];
    pathConfig.PathChanged = "%h/.local/share/flatpak/exports/share/applications";
  };
}
