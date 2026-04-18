case $- in
*i*) ;;
*) return;;
esac

alias bun="steam-run ~/.bun/bin/bun"
alias bunx="steam-run ~/.bun/bin/bunx"
alias fdp="sudo codium /etc/nixos/ --user-data-dir /home/kisakay/ --no-sandbox #sudo nano /etc/nixos/configuration.nix"
alias m2f="cd /etc/nixos/; sudo nixos-rebuild switch --flake /etc/nixos#computer"
alias whatsmyip="curl ifconfig.me; echo"

alias tgl="gsettings set org.gnome.desktop.peripherals.touchpad send-events 'disabled'"
alias revien="gsettings reset org.gnome.desktop.peripherals.touchpad send-events"
alias bat="acpi"
alias maj="sudo nix-channel --update"

alias vpnon="sudo systemctl restart wg-quick-wg0"
alias vpnoff='sudo systemctl stop wg-quick-wg0'

export PATH="/home/kisakay/.bun/bin:$PATH"
export PATH=$PATH:/home/kisakay/.spicetify

# if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1; then
#    onefetch
# else
#    fastfetch
# fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# export NVM_DIR="$HOME/.config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export MESA_SHADER_CACHE_MAX_SIZE=10G
export MESA_SHADER_CACHE_DIR=$HOME/.cache/mesa_shader_cache
export __GL_SHADER_DISK_CACHE=1
