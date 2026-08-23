# nixos-config

Configuration NixOS flake-based pour un **Framework 13** (Ryzen 5 7640U, AMD), desktop COSMIC.

## Structure

```
.
├── flake.nix               # Point d'entrée : inputs (nixpkgs, qxchat, zen-browser) + hosts
├── hosts/
│   └── computer/           # La machine
│       ├── default.nix     # Glue : hostname, stateVersion, imports
│       └── hardware-configuration.nix  # Généré par nixos-generate-config
└── modules/
    └── nixos/
        ├── boot.nix        # systemd-boot, kernel, v4l2loopback (OBS Cam)
        ├── networking.nix  # NetworkManager, firewall, SSH
        ├── locale.nix      # Timezone FR, locales, console, clavier
        ├── users.nix       # kisakay
        ├── security.nix    # polkit (+ règle fwupd)
        ├── nix.nix         # flakes, GC auto, allowUnfree
        ├── desktop/        # COSMIC, audio (PipeWire), polices/theming
        ├── hardware/       # GPU AMD, Framework (fwupd/fanctrl/fprintd), imprimante
        ├── virtualisation/ # libvirtd/virt-manager, podman + docker rootless
        ├── development/    # nix-ld, ccache, lorri, env de compilation (openssl/curl)
        ├── programs/       # Firefox/Zen/Chromium/Tor, OBS, Steam, QxChat
        ├── services/       # Flatpak, PostgreSQL, PM2
        └── packages/       # Paquets classés : base, desktop, dev, media, nettools, office
```

## Utilisation

```bash
# Appliquer la config
sudo nixos-rebuild switch --flake /etc/nixos#computer

# Mettre à jour les inputs
nix flake update

# Formater le code
nix fmt
```

## Notes

- Le firewall est **activé** avec une allowlist explicite (TCP : 22, 80, 443, 3000, 3001, 3871, 4560, 8000, 25565 — UDP : 53, 51820). Ajouter les ports nécessaires dans `modules/nixos/networking.nix`.
- Le GC nix tourne chaque semaine et supprime les générations de plus de 30 jours (`modules/nixos/nix.nix`).
- Les paquets sont dédupliqués et regroupés par thème ; chaque module porte sa logique (ex. OBS + v4l2loopback côté boot).
