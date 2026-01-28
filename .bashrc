case $- in
*i*) ;;
*) return;;
esac

alias bun="steam-run ~/.bun/bin/bun"
alias bunx="steam-run ~/.bun/bin/bunx"
alias fdp="sudo codium /etc/nixos/ --user-data-dir /home/kisakay/ --no-sandbox #sudo nano /etc/nixos/configuration.nix"
alias m2f="sudo nixos-rebuild switch"
alias whatsmyip="curl ifconfig.me; echo"

alias tgl="gsettings set org.gnome.desktop.peripherals.touchpad send-events 'disabled'"
alias revien="gsettings reset org.gnome.desktop.peripherals.touchpad send-events"
alias bat="acpi"
alias maj="sudo nix-channel --update"

export PATH="/home/kisakay/.bun/bin:$PATH"
export PATH=$PATH:/home/kisakay/.spicetify

if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1; then
    onefetch
else
    fastfetch
fi
