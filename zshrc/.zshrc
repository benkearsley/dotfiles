source "$HOME/.config/zshrc/init"
source "$HOME/.config/zshrc/envs"
source "$HOME/.config/zshrc/shell"
source "$HOME/.config/zshrc/aliases"
source "$HOME/.config/zshrc/prompt"

if [[ -o interactive ]]; then
  [[ -f "$HOME/.config/inputrc" ]] && source "$HOME/.config/inputrc"
fi

PATH="/Library/Java/JavaVirtualMachines/jdk-25.jdk/Contents/Home/bin:$PATH"
PATH="$HOME/bin:$PATH"
#mcp-cli:binary path
export MCP_CLI_BIN=/Users/b0k07eo/.mcp-cli/bin
export PATH="${PATH}:${MCP_CLI_BIN}"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/b0k07eo/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

. "$HOME/.local/bin/env"

# Added by Code Puppy installer on Wed Dec 10 16:34:33 CST 2025
alias code-puppy="$HOME/.code-puppy-venv/bin/code-puppy"
export $(grep puppy_token ~/.code_puppy/puppy.cfg | sed 's| ||g')

# Added by Wibey CLI installation
export PATH="/Users/b0k07eo/.local/bin:$PATH"
