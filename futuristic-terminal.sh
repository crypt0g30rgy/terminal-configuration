#!/bin/bash
# Futuristic Terminal Installer for Parrot OS
# Usage: ./futuristic-terminal.sh --init | --revert

CONFIG_BACKUP="$HOME/.terminal_backup"
FONT_DIR="$HOME/.local/share/fonts"
STARSHIP_BIN="/usr/local/bin/starship"
STARSHIP_CONFIG="$HOME/.config/starship.toml"

init_terminal() {
    echo "⚡ Setting up Futuristic Terminal on Parrot OS..."

    # Backup configs
    mkdir -p "$CONFIG_BACKUP"
    cp -f "$HOME/.zshrc" "$CONFIG_BACKUP/zshrc.bak" 2>/dev/null

    # Install dependencies
    echo "➡ Installing Starship prompt..."
    if [ ! -f "$STARSHIP_BIN" ]; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    echo "➡ Installing FiraCode Nerd Font..."
    mkdir -p "$FONT_DIR"
    wget -qO "$FONT_DIR/FiraCode.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"
    unzip -o "$FONT_DIR/FiraCode.zip" -d "$FONT_DIR"
    fc-cache -fv >/dev/null

    echo "➡ Installing Neofetch + cmatrix + Zsh plugins..."
    sudo apt update && sudo apt install -y neofetch cmatrix git zsh

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.zsh-autosuggestions

    # Apply Catppuccin theme (GNOME Terminal)
    echo "➡ Applying Catppuccin color scheme..."
    git clone https://github.com/catppuccin/gnome-terminal.git /tmp/catppuccin-terminal
    /tmp/catppuccin-terminal/install.sh -n Catppuccin-Macchiato -p default
    rm -rf /tmp/catppuccin-terminal

    # Configure Zsh startup sequence
    echo "➡ Configuring Zsh..."
    cat <<'EOF' >> "$HOME/.zshrc"

# 🚀 Futuristic startup sequence
if command -v cmatrix &> /dev/null; then
    # Pick a random color from the list
    COLORS=("green" "red" "blue" "white" "yellow" "cyan" "magenta" "black")
    RAND_COLOR=${COLORS[$RANDOM % ${#COLORS[@]}]}

    if command -v timeout &> /dev/null; then
        timeout 2 cmatrix -C "$RAND_COLOR" -b -u 5
    elif command -v gtimeout &> /dev/null; then
        gtimeout 2 cmatrix -C "$RAND_COLOR" -b -u 5
    fi

    # Clean screen after animation
    reset
fi

if [ -x "$(command -v neofetch)" ]; then
    neofetch
fi

# Starship prompt
eval "$(starship init zsh)"

# Syntax highlighting + autosuggestions
source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Add History file
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
EOF

    # Create custom Starship config
    echo "➡ Applying Cyberpunk Starship config..."
    mkdir -p "$(dirname $STARSHIP_CONFIG)"
    cat <<'EOF' > "$STARSHIP_CONFIG"
# Cyberpunk Starship Prompt ✨

add_newline = true

format = """
[░▒▓](cyan) us3r@$hostname [▓▒░](purple) 
[┌─](bold cyan)$directory$git_branch$git_status
[└─>](bold purple) """

[username]
style_user = "bold red"
style_root = "bold red"
format = "[$user]($style)"
disabled = false

[hostname]
ssh_only = false
format = "[$hostname](bold yellow)"

[directory]
style = "bold cyan"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = "🌱 "
style = "bold purple"

[git_status]
style = "bold red"
format = '([$all_status$ahead_behind]($style))'

[cmd_duration]
format = " ⏱ [$duration](bold blue)"

[time]
disabled = false
time_format = "%H:%M:%S"
style = "bold magenta"
format = " 🕒 [$time]($style)"
EOF

    echo "✅ Futuristic Terminal installed! Restart your terminal."
}

revert_terminal() {
    echo "⏪ Reverting to previous terminal setup..."

    if [ -f "$CONFIG_BACKUP/zshrc.bak" ]; then
        cp -f "$CONFIG_BACKUP/zshrc.bak" "$HOME/.zshrc"
    fi

    if [ -f "$STARSHIP_CONFIG" ]; then
        rm -f "$STARSHIP_CONFIG"
    fi

    if [ -f "$STARSHIP_BIN" ]; then
        echo "➡ Removing Starship..."
        sudo rm -f "$STARSHIP_BIN"
    fi

    echo "➡ Removing Nerd Fonts..."
    rm -rf "$FONT_DIR/FiraCode*"

    echo "✅ Terminal reverted to original state."
}

case "$1" in
    --init)
        init_terminal
        ;;
    --revert)
        revert_terminal
        ;;
    *)
        echo "Usage: $0 --init | --revert"
        ;;
esac
