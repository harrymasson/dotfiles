# ~/.config/zsh/conf.d/50-apps.zsh
# Purpose: PATH additions and env config for GUI applications.
# Source: chezmoi: home/dot_config/zsh/conf.d/50-apps.zsh

# Obsidian CLI — available when "URI Shell Commands" or similar CLI plugin is enabled in Obsidian settings
[[ -d "/Applications/Obsidian.app/Contents/MacOS" ]] && export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
