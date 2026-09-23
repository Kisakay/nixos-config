# nixos-config

Configuration NixOS flake-based pour un **Framework 13** (Ryzen 5 7640U, AMD), desktop COSMIC.

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
