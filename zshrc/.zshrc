
source "$HOME/.config/zshrc/init"
source "$HOME/.config/zshrc/envs"
source "$HOME/.config/zshrc/shell"
source "$HOME/.config/zshrc/aliases"
source "$HOME/.config/zshrc/prompt"

if [[ -o interactive ]]; then
  [[ -f "$HOME/.config/inputrc" ]] && source "$HOME/.config/inputrc"
fi

