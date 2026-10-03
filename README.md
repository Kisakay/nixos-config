# Configuration NixOS — machine « framework-laptop-12 »

Arborescence :

```
.
├── flake.nix                    # Entrée du flake (inputs + nixosConfigurations.framework-laptop-12)
├── flake.lock
├── hosts/
│   └── framework-laptop-12/
│       ├── default.nix          # Point d'entrée de la machine « framework-laptop-12 »
│       └── hardware-configuration.nix  # Généré par nixos-generate-config
└── modules/
    ├── default.nix              # Agrège les modules ci-dessous
    ├── boot.nix                 # Bootloader, noyau, LUKS
    ├── desktop.nix              # X11, GNOME, PipeWire
    ├── flake-packages.nix       # QxChat, Zen Browser (inputs du flake)
    ├── hardware.nix             # Impression
    ├── locale.nix               # Fuseau horaire, i18n
    ├── network.nix              # Réseau, pare-feu
    ├── nix.nix                  # Nix / nixpkgs
    ├── packages.nix             # Paquets système
    ├── programs.nix             # Firefox, shell
    ├── ssh.nix                  # SSH (serveur + client)
    ├── users.nix                # Utilisateurs
    └── vpn.nix                  # VPN WireGuard
```

## Reconstruire

```sh
sudo nixos-rebuild switch --flake /etc/nixos#framework-laptop-12
```

> `nixos-generate-config` régénère `configuration.nix` et `hardware-configuration.nix`
> à la racine de `/etc/nixos` : en cas de réexécution, replacer le résultat dans
> `hosts/framework-laptop-12/`.
