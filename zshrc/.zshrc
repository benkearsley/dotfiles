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

# Added by Wibey CLI installation
export PATH="/Users/b0k07eo/.local/bin:$PATH"

mcp-cli auth login
if [ -f "$HOME/.mcp-cli/tokens.json" ]; then
  export PING_TOKEN=$(python3 -c "import json, os; print(json.load(open(os.path.expanduser('~/.mcp-cli/tokens.json'))).get('access_token', ''))" 2>/dev/null)
fi

# Added by Wibey CLI installation
export BUN_INSTALL_CACHE_DIR="/Users/b0k07eo/.local/share/bun/cache"
