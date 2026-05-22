#!/bin/bash
# ============================================
# Myfurina — One-click AI Agent Installer
# Supports: Hermes Agent & OpenClaw
# ============================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

INSTALL_DIR="$HOME/.superagent"
BRAIN_DIR="$INSTALL_DIR/brain"
SKILLS_DIR="$BRAIN_DIR/skills"
MEMORY_DIR="$BRAIN_DIR/memory"

# [FIX #8] Explicit error handler
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}  Warning: $1${NC}" >&2
}

# ============================================
# Banner
# ============================================
echo -e "${MAGENTA}${BOLD}"
echo "  ███╗   ███╗██╗   ██╗███████╗██╗   ██╗██████╗ ██╗███╗   ██╗ █████╗ "
echo "  ████╗ ████║╚██╗ ██╔╝██╔════╝██║   ██║██╔══██╗██║████╗  ██║██╔══██╗"
echo "  ██╔████╔██║ ╚████╔╝ █████╗  ██║   ██║██████╔╝██║██╔██╗ ██║███████║"
echo "  ██║╚██╔╝██║  ╚██╔╝  ██╔══╝  ██║   ██║██╔══██╗██║██║╚██╗██║██╔══██║"
echo "  ██║ ╚═╝ ██║   ██║   ██║     ╚██████╔╝██║  ██║██║██║ ╚████║██║  ██║"
echo "  ╚═╝     ╚═╝   ╚═╝   ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${CYAN}  One-click installer for AI Agent + Brain System${NC}"
echo ""

# ============================================
# System Check
# ============================================
echo -e "${YELLOW}[1/8] System check...${NC}"

if [[ "$(uname)" != "Linux" ]]; then
    error_exit "This installer only supports Linux."
fi

if [[ $EUID -ne 0 ]]; then
    error_exit "Please run as root (sudo ./install.sh)"
fi

# [FIX #5] Detect distro — only support Debian/Ubuntu with clear error
DISTRO_ID=""
if [[ -f /etc/os-release ]]; then
    DISTRO_ID=$(. /etc/os-release && echo "$ID")
fi

case "$DISTRO_ID" in
    ubuntu|debian|linuxmint|pop)
        PKG_MANAGER="apt-get"
        echo -e "${GREEN}  ✓ Linux detected ($DISTRO_ID)${NC}"
        ;;
    centos|rhel|fedora|rocky|almalinux)
        PKG_MANAGER="yum"
        echo -e "${GREEN}  ✓ Linux detected ($DISTRO_ID)${NC}"
        ;;
    arch|manjaro)
        PKG_MANAGER="pacman"
        echo -e "${GREEN}  ✓ Linux detected ($DISTRO_ID)${NC}"
        ;;
    *)
        if command -v apt-get &>/dev/null; then
            PKG_MANAGER="apt-get"
            echo -e "${GREEN}  ✓ Linux detected (unknown distro, using apt-get)${NC}"
        elif command -v yum &>/dev/null; then
            PKG_MANAGER="yum"
            echo -e "${GREEN}  ✓ Linux detected (unknown distro, using yum)${NC}"
        else
            error_exit "Unsupported distro: $DISTRO_ID. Requires apt-get or yum."
        fi
        ;;
esac

echo -e "${GREEN}  ✓ Running as root${NC}"
echo ""

# ============================================
# Choose Agent Framework
# ============================================
echo -e "${YELLOW}[2/8] Choose your AI agent framework:${NC}"
echo ""
echo -e "  ${BOLD}1)${NC} ${CYAN}Hermes Agent${NC} — by Nous Research"
echo -e "     • Skills system, persistent memory, multi-platform gateway"
echo -e "     • 20+ providers, profiles, cron jobs, MCP servers"
echo -e "     • Config: ~/.hermes/config.yaml (YAML)"
echo ""
echo -e "  ${BOLD}2)${NC} ${CYAN}OpenClaw${NC} — AI agent framework"
echo -e "     • Gateway-based, tool calling, session management"
echo -e "     • 30+ built-in providers, custom provider support"
echo -e "     • Config: ~/.openclaw/openclaw.json (JSON)"
echo ""

AGENT_CHOICE=""
while [[ "$AGENT_CHOICE" != "1" && "$AGENT_CHOICE" != "2" ]]; do
    echo -e -n "${CYAN}  Enter choice (1 or 2): ${NC}"
    read -r AGENT_CHOICE
done

if [[ "$AGENT_CHOICE" == "1" ]]; then
    AGENT_NAME="Hermes"
    echo -e "${GREEN}  ✓ Selected: Hermes Agent${NC}"
else
    AGENT_NAME="OpenClaw"
    echo -e "${GREEN}  ✓ Selected: OpenClaw${NC}"
fi
echo ""

# ============================================
# Install Dependencies
# ============================================
echo -e "${YELLOW}[3/8] Installing dependencies...${NC}"

install_packages() {
    case "$PKG_MANAGER" in
        apt-get)
            apt-get update -qq || warn "apt-get update failed"
            apt-get install -y -qq "$@" 2>&1 || error_exit "Failed to install: $*"
            ;;
        yum)
            yum install -y -q "$@" 2>&1 || error_exit "Failed to install: $*"
            ;;
        pacman)
            pacman -S --noconfirm --needed "$@" 2>&1 || error_exit "Failed to install: $*"
            ;;
    esac
}

PACKAGES_TO_INSTALL=""
for pkg in curl wget git python3; do
    if ! command -v "$pkg" &> /dev/null; then
        PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $pkg"
    else
        echo -e "${GREEN}  ✓ $pkg already installed${NC}"
    fi
done

if [[ -n "$PACKAGES_TO_INSTALL" ]]; then
    echo -e "${CYAN}  Installing:$PACKAGES_TO_INSTALL${NC}"
    install_packages $PACKAGES_TO_INSTALL
    echo -e "${GREEN}  ✓ Installed:$PACKAGES_TO_INSTALL${NC}"
fi

# [FIX #3] Install pyyaml for Python YAML config
echo -e "${CYAN}  Checking Python packages...${NC}"
if ! python3 -c "import yaml" 2>/dev/null; then
    echo -e "${CYAN}  Installing pyyaml...${NC}"
    pip3 install pyyaml 2>&1 || {
        # Fallback: try with --break-system-packages for newer Python
        pip3 install --break-system-packages pyyaml 2>&1 || warn "pyyaml install failed — YAML config may not work"
    }
    if python3 -c "import yaml" 2>/dev/null; then
        echo -e "${GREEN}  ✓ pyyaml installed${NC}"
    fi
else
    echo -e "${GREEN}  ✓ pyyaml already installed${NC}"
fi

# Node.js
if ! command -v node &> /dev/null; then
    echo -e "${CYAN}  Installing Node.js...${NC}"
    # [FIX #6] Don't suppress errors — check exit code
    if [[ "$PKG_MANAGER" == "apt-get" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - || error_exit "Failed to setup Node.js repository"
        apt-get install -y -qq nodejs || error_exit "Failed to install Node.js"
    elif [[ "$PKG_MANAGER" == "yum" ]]; then
        curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - || error_exit "Failed to setup Node.js repository"
        yum install -y -q nodejs || error_exit "Failed to install Node.js"
    else
        error_exit "Please install Node.js manually: https://nodejs.org"
    fi
    if command -v node &> /dev/null; then
        echo -e "${GREEN}  ✓ Node.js installed ($(node --version))${NC}"
    else
        error_exit "Node.js installation failed"
    fi
else
    echo -e "${GREEN}  ✓ Node.js already installed ($(node --version))${NC}"
fi

if ! command -v npm &> /dev/null; then
    echo -e "${CYAN}  Installing npm...${NC}"
    case "$PKG_MANAGER" in
        apt-get) apt-get install -y -qq npm 2>&1 || warn "npm install failed" ;;
        yum) yum install -y -q npm 2>&1 || warn "npm install failed" ;;
    esac
    if command -v npm &> /dev/null; then
        echo -e "${GREEN}  ✓ npm installed${NC}"
    fi
else
    echo -e "${GREEN}  ✓ npm already installed${NC}"
fi
echo ""

# ============================================
# Install Agent Framework
# ============================================
echo -e "${YELLOW}[4/8] Installing $AGENT_NAME...${NC}"

if [[ "$AGENT_CHOICE" == "1" ]]; then
    if command -v hermes &> /dev/null; then
        echo -e "${GREEN}  ✓ Hermes already installed${NC}"
    else
        echo -e "${CYAN}  Installing Hermes Agent...${NC}"
        curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash || error_exit "Hermes installation failed"
        if ! command -v hermes &> /dev/null; then
            error_exit "Hermes installation failed. Try manually: curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
        fi
        echo -e "${GREEN}  ✓ Hermes installed successfully${NC}"
    fi
else
    if command -v openclaw &> /dev/null; then
        echo -e "${GREEN}  ✓ OpenClaw already installed${NC}"
    else
        echo -e "${CYAN}  Installing OpenClaw via npm...${NC}"
        if npm install -g openclaw 2>&1; then
            echo -e "${GREEN}  ✓ OpenClaw installed via npm${NC}"
        else
            # [FIX #4] Robust fallback — verify clone before building
            echo -e "${YELLOW}  npm install failed, trying from source...${NC}"
            CLONE_DIR=$(mktemp -d /tmp/openclaw-XXXXXX)
            if git clone https://github.com/openclaw/openclaw.git "$CLONE_DIR" 2>&1; then
                cd "$CLONE_DIR" && npm install && npm link
                cd /tmp && rm -rf "$CLONE_DIR"
                echo -e "${GREEN}  ✓ OpenClaw installed from source${NC}"
            else
                rm -rf "$CLONE_DIR"
                error_exit "OpenClaw installation failed. Try manually: npm install -g openclaw"
            fi
        fi

        if ! command -v openclaw &> /dev/null; then
            error_exit "OpenClaw not found after installation. Try manually: npm install -g openclaw"
        fi
    fi
fi
echo ""

# ============================================
# Collect API Configuration
# ============================================
echo -e "${YELLOW}[5/8] API Configuration${NC}"
echo ""

echo -e -n "${CYAN}  Enter your API Key: ${NC}"
read -r API_KEY
while [[ -z "$API_KEY" ]]; do
    echo -e "${RED}  API Key is required!${NC}"
    echo -e -n "${CYAN}  Enter your API Key: ${NC}"
    read -r API_KEY
done

echo -e -n "${CYAN}  Enter Base URL (default: https://api.openai.com/v1): ${NC}"
read -r BASE_URL
BASE_URL=${BASE_URL:-"https://api.openai.com/v1"}

echo -e -n "${CYAN}  Enter Model name (e.g., gpt-4o, claude-sonnet-4): ${NC}"
read -r MODEL_NAME
while [[ -z "$MODEL_NAME" ]]; do
    echo -e "${RED}  Model name is required!${NC}"
    echo -e -n "${CYAN}  Enter Model name: ${NC}"
    read -r MODEL_NAME
done

echo ""
# [FIX #7] Only show first 4 chars of credential
echo -e "${GREEN}  ✓ API Key: ${API_KEY:0:4}****${NC}"
echo -e "${GREEN}  ✓ Base URL: $BASE_URL${NC}"
echo -e "${GREEN}  ✓ Model: $MODEL_NAME${NC}"
echo ""

# ============================================
# Telegram Integration
# ============================================
echo -e "${YELLOW}[6/8] Telegram Integration${NC}"
echo ""

echo -e -n "${CYAN}  Enter Telegram Bot Token (required): ${NC}"
read -r TELEGRAM_BOT_TOKEN
while [[ -z "$TELEGRAM_BOT_TOKEN" ]]; do
    echo -e "${RED}  Telegram Bot Token is required!${NC}"
    echo -e -n "${CYAN}  Enter Telegram Bot Token: ${NC}"
    read -r TELEGRAM_BOT_TOKEN
done

# [FIX #10] Validate Telegram Chat ID format (numeric, optional leading -)
echo -e -n "${CYAN}  Enter your Telegram Chat ID (required): ${NC}"
read -r TELEGRAM_CHAT_ID
while true; do
    if [[ -z "$TELEGRAM_CHAT_ID" ]]; then
        echo -e "${RED}  Telegram Chat ID is required!${NC}"
    elif [[ ! "$TELEGRAM_CHAT_ID" =~ ^-?[0-9]+$ ]]; then
        echo -e "${RED}  Invalid Chat ID! Must be numeric (e.g., 123456789 or -1001234567890)${NC}"
    else
        break
    fi
    echo -e -n "${CYAN}  Enter your Telegram Chat ID: ${NC}"
    read -r TELEGRAM_CHAT_ID
done

echo ""
# [FIX #7] Only show first 4 chars
echo -e "${GREEN}  ✓ Bot Token: ${TELEGRAM_BOT_TOKEN:0:4}****${NC}"
echo -e "${GREEN}  ✓ Chat ID: $TELEGRAM_CHAT_ID${NC}"
echo ""

# ============================================
# User Profile
# ============================================
echo -e "${YELLOW}[7/8] User Profile${NC}"
echo ""

echo -e -n "${CYAN}  Enter your name: ${NC}"
read -r USER_NAME
USER_NAME=${USER_NAME:-"User"}

echo -e -n "${CYAN}  Enter your username: ${NC}"
read -r USER_USERNAME
USER_USERNAME=${USER_USERNAME:-"user"}

echo -e -n "${CYAN}  Enter preferred language (default: English): ${NC}"
read -r USER_LANG
USER_LANG=${USER_LANG:-"English"}

echo -e -n "${CYAN}  Communication style (default: direct and casual): ${NC}"
read -r USER_STYLE
USER_STYLE=${USER_STYLE:-"direct and casual"}

echo ""
echo -e "${GREEN}  ✓ Name: $USER_NAME${NC}"
echo -e "${GREEN}  ✓ Language: $USER_LANG${NC}"
echo ""

# ============================================
# Setup Brain & Configure Agent
# ============================================
echo -e "${YELLOW}[8/8] Setting up brain & configuring $AGENT_NAME...${NC}"

# Create directories with secure permissions
mkdir -p "$BRAIN_DIR" "$SKILLS_DIR" "$MEMORY_DIR"
chmod 700 "$INSTALL_DIR"
chmod 700 "$BRAIN_DIR"
chmod 700 "$SKILLS_DIR"
chmod 700 "$MEMORY_DIR"

# Create .gitignore
cat > "$INSTALL_DIR/.gitignore" << 'EOF'
config.env
.env
*.key
*.pem
*.token
brain/MEMORY.md
brain/USER.md
EOF
echo -e "${GREEN}  ✓ .gitignore created${NC}"

# Save config.env
cat > "$INSTALL_DIR/config.env" << EOF
API_KEY=$API_KEY
BASE_URL=$BASE_URL
MODEL=$MODEL_NAME
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID
AGENT_FRAMEWORK=$AGENT_NAME
EOF
chmod 600 "$INSTALL_DIR/config.env"
echo -e "${GREEN}  ✓ Config saved (chmod 600)${NC}"

# Create brain files
cat > "$BRAIN_DIR/USER.md" << EOF
# USER.md — Owner Profile

**Name**: $USER_NAME
**Username**: $USER_USERNAME
**Language**: $USER_LANG
**Style**: $USER_STYLE
EOF
chmod 600 "$BRAIN_DIR/USER.md"

cat > "$BRAIN_DIR/MEMORY.md" << EOF
# MEMORY.md — Long-term Context

## System
- Agent: $AGENT_NAME
- Model: $MODEL_NAME
- Language: $USER_LANG
- Installed: $(date)
EOF
chmod 600 "$BRAIN_DIR/MEMORY.md"

cat > "$BRAIN_DIR/TOOLS.md" << EOF
# TOOLS.md — Available Tools

## AI Provider
- Framework: $AGENT_NAME
- Model: $MODEL_NAME
- Base URL: $BASE_URL

## Messaging
- Telegram: ✓ Configured
EOF
chmod 600 "$BRAIN_DIR/TOOLS.md"
echo -e "${GREEN}  ✓ Brain files created (chmod 600)${NC}"

# ============================================
# Configure Agent Framework
# ============================================
if [[ "$AGENT_CHOICE" == "1" ]]; then
    # === HERMES CONFIG ===
    echo -e "${CYAN}  Configuring Hermes Agent...${NC}"

    # Step 1: Set custom provider
    hermes config set custom_providers.myfurina.name "Myfurina Provider" 2>&1 || warn "provider name"
    hermes config set custom_providers.myfurina.base_url "$BASE_URL" 2>&1 || warn "base_url"
    hermes config set custom_providers.myfurina.api_key "$API_KEY" 2>&1 || warn "api_key"
    hermes config set custom_providers.myfurina.model "$MODEL_NAME" 2>&1 || warn "model"
    hermes config set main_provider "custom:myfurina" 2>&1 || warn "main_provider"
    echo -e "${GREEN}  ✓ Custom provider configured${NC}"

    # Step 2: Create .env file
    HERMES_ENV="$HOME/.hermes/.env"
    mkdir -p "$HOME/.hermes"
    touch "$HERMES_ENV"
    if ! grep -q "Myfurina Configuration" "$HERMES_ENV" 2>/dev/null; then
        cat >> "$HERMES_ENV" << EOF

# Myfurina Configuration
OPENAI_API_KEY=$API_KEY
OPENAI_BASE_URL=$BASE_URL
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
EOF
    fi
    chmod 600 "$HERMES_ENV"
    echo -e "${GREEN}  ✓ Environment variables set${NC}"

    # Step 3: Configure Telegram
    # [FIX #2] allowed_chats is a list, [FIX #3] pyyaml already installed
    python3 << PYEOF
import yaml
import os

config_path = os.path.expanduser("~/.hermes/config.yaml")
os.makedirs(os.path.dirname(config_path), exist_ok=True)

config = {}
if os.path.exists(config_path):
    try:
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f) or {}
    except Exception as e:
        print(f"Warning: Could not parse config.yaml: {e}")
        config = {}

# Set TOP-LEVEL telegram section (not channels.telegram!)
config['telegram'] = {
    'allowed_chats': ['$TELEGRAM_CHAT_ID'],
    'bot_token': '$TELEGRAM_BOT_TOKEN',
    'enabled': True,
    'channel_prompts': {},
    'reactions': False
}

# Remove any wrong channels.telegram if it exists
if 'channels' in config and 'telegram' in config.get('channels', {}):
    del config['channels']['telegram']

with open(config_path, 'w') as f:
    yaml.dump(config, f, default_flow_style=False, allow_unicode=True)

print("Telegram configured at top-level telegram: section")
PYEOF

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}  ✓ Telegram configured (top-level telegram: section)${NC}"
    else
        warn "Python YAML config failed — run: hermes config edit"
    fi

    # Step 4: Restrict permissions
    chmod 600 "$HOME/.hermes/config.yaml" 2>/dev/null || true

    # Step 5: Verify
    echo -e "${CYAN}  Verifying...${NC}"
    if grep -q "custom:myfurina" "$HOME/.hermes/config.yaml" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Custom provider verified${NC}"
    else
        warn "Custom provider not in config"
    fi
    if grep -q "bot_token" "$HOME/.hermes/config.yaml" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Telegram config verified${NC}"
    else
        warn "Telegram config not in config"
    fi

else
    # === OPENCLAW CONFIG ===
    echo -e "${CYAN}  Configuring OpenClaw...${NC}"

    mkdir -p "$HOME/.openclaw"
    OPENCLAW_CONFIG="$HOME/.openclaw/openclaw.json"

    cat > "$OPENCLAW_CONFIG" << EOF
{
  "gateway": {
    "mode": "local",
    "auth": { "mode": "token" }
  },
  "models": {
    "providers": {
      "custom": {
        "baseUrl": "$BASE_URL",
        "apiKey": "$API_KEY",
        "models": [{
          "id": "$MODEL_NAME",
          "name": "$MODEL_NAME",
          "api": "openai-completions",
          "contextWindow": 128000,
          "maxTokens": 8192
        }]
      }
    }
  },
  "telegram": {
    "botToken": "$TELEGRAM_BOT_TOKEN",
    "chatId": "$TELEGRAM_CHAT_ID",
    "enabled": true
  },
  "commands": {
    "ownerAllowFrom": "telegram:$TELEGRAM_CHAT_ID"
  }
}
EOF
    chmod 600 "$OPENCLAW_CONFIG"
    echo -e "${GREEN}  ✓ OpenClaw config created${NC}"

    # Try config patch
    OPENCLAW_PATCH=$(mktemp /tmp/openclaw-patch-XXXXXX.json)
    chmod 600 "$OPENCLAW_PATCH"
    cat > "$OPENCLAW_PATCH" << EOF
{
  "gateway": { "mode": "local", "auth": { "mode": "token" } },
  "models": { "providers": { "custom": {
    "baseUrl": "$BASE_URL",
    "apiKey": "$API_KEY",
    "models": [{ "id": "$MODEL_NAME", "name": "$MODEL_NAME", "api": "openai-completions", "contextWindow": 128000, "maxTokens": 8192 }]
  }}},
  "telegram": { "botToken": "$TELEGRAM_BOT_TOKEN", "chatId": "$TELEGRAM_CHAT_ID", "enabled": true },
  "commands": { "ownerAllowFrom": "telegram:$TELEGRAM_CHAT_ID" }
}
EOF
    openclaw config patch --file "$OPENCLAW_PATCH" 2>&1 || warn "Patch warnings (config file already created)"
    shred -u "$OPENCLAW_PATCH" 2>/dev/null || rm -f "$OPENCLAW_PATCH"

    # Save .env
    cat > "$INSTALL_DIR/.env" << EOF
OPENAI_API_KEY=$API_KEY
OPENAI_BASE_URL=$BASE_URL
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID
EOF
    chmod 600 "$INSTALL_DIR/.env"
    echo -e "${GREEN}  ✓ OpenClaw configured${NC}"
fi

# ============================================
# Start/Stop Scripts
# [FIX #1] Heredoc: header is quoted (static), body is unquoted (vars expand)
# ============================================
cat > "$INSTALL_DIR/start.sh" << 'STARTEOF'
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'
echo -e "${CYAN}Starting Myfurina...${NC}"
echo -e "${GREEN}Agent: $AGENT_FRAMEWORK${NC}"
echo -e "${GREEN}Model: $MODEL${NC}"
STARTEOF

# [FIX #1] Unquoted heredoc — $API_KEY and $BASE_URL expand at install time
if [[ "$AGENT_CHOICE" == "1" ]]; then
    cat >> "$INSTALL_DIR/start.sh" << STARTEOF
export OPENAI_API_KEY="$API_KEY"
export OPENAI_BASE_URL="$BASE_URL"
if ! command -v hermes &> /dev/null; then
    echo -e "\033[0;31mError: hermes not found\033[0m"; exit 1
fi
if [[ ! -f "\$HOME/.hermes/config.yaml" ]]; then
    echo -e "\033[0;31mError: config.yaml not found\033[0m"; exit 1
fi
echo -e "\033[0;36mStarting Hermes gateway...\033[0m"
hermes gateway start
echo -e "\033[0;32m✓ Myfurina is running!\033[0m"
echo -e "  Chat: Telegram | Stop: ~/.superagent/stop.sh"
STARTEOF
else
    cat >> "$INSTALL_DIR/start.sh" << STARTEOF
export OPENAI_API_KEY="$API_KEY"
export OPENAI_BASE_URL="$BASE_URL"
export TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
export TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"
if ! command -v openclaw &> /dev/null; then
    echo -e "\033[0;31mError: openclaw not found\033[0m"; exit 1
fi
echo -e "\033[0;36mStarting OpenClaw gateway...\033[0m"
openclaw gateway start
echo -e "\033[0;32m✓ Myfurina is running!\033[0m"
echo -e "  Chat: Telegram | Stop: ~/.superagent/stop.sh"
STARTEOF
fi
chmod +x "$INSTALL_DIR/start.sh"

cat > "$INSTALL_DIR/stop.sh" << 'STOPEOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"
GREEN='\033[0;32m'
NC='\033[0m'
echo "Stopping Myfurina..."
STOPEOF
if [[ "$AGENT_CHOICE" == "1" ]]; then
    echo 'hermes gateway stop 2>/dev/null || true' >> "$INSTALL_DIR/stop.sh"
    echo 'echo -e "${GREEN}✓ Stopped${NC}"' >> "$INSTALL_DIR/stop.sh"
else
    echo 'openclaw gateway stop 2>/dev/null || true' >> "$INSTALL_DIR/stop.sh"
    echo 'echo -e "${GREEN}✓ Stopped${NC}"' >> "$INSTALL_DIR/stop.sh"
fi
chmod +x "$INSTALL_DIR/stop.sh"
echo -e "${GREEN}  ✓ Start/Stop scripts created${NC}"

# ============================================
# Done!
# ============================================
echo ""
echo -e "${MAGENTA}${BOLD}"
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║           🎉 Myfurina Installation Complete! 🎉          ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "  ${BOLD}Framework:${NC} $AGENT_NAME"
echo -e "  ${BOLD}Model:${NC}     $MODEL_NAME"
echo -e "  ${BOLD}Telegram:${NC}  Chat ID: $TELEGRAM_CHAT_ID"
echo ""
echo -e "  ${CYAN}Start:${NC}  ~/.superagent/start.sh"
echo -e "  ${CYAN}Stop:${NC}   ~/.superagent/stop.sh"
echo -e "  ${CYAN}Config:${NC} $INSTALL_DIR/config.env"
echo ""
if [[ "$AGENT_CHOICE" == "1" ]]; then
    echo -e "  ${YELLOW}Hermes config:${NC} ~/.hermes/config.yaml"
else
    echo -e "  ${YELLOW}OpenClaw config:${NC} ~/.openclaw/openclaw.json"
fi
echo ""
echo -e "${GREEN}  Run: ~/.superagent/start.sh${NC}"
echo ""
