
source "$HOME/.config/init"
source "$HOME/.config/shell"
source "$HOME/.config/aliases"
source "$HOME/.config/functions"
source "$HOME/.config/prompt"

if [[ -o interactive ]]; then
  [[ -f "$HOME/.config/inputrc" ]] && source "$HOME/.config/inputrc"
fi

