#!/bin/bash
set -e

# ============================================
# Myfurina — One-click AI Agent Installer
# Supports: Hermes Agent & OpenClaw
# ============================================

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

# ============================================
# Banner
# ============================================
echo -e "${MAGENTA}${BOLD}"
echo "  ███╗   ███╗██╗   ██╗███████╗██╗   ██╗██████╗ ██╗███╗   ██╗ █████╗ "
echo "  ████╗ ████║╚██╗ ██╔╝██╔════╝██║   ██║██╔══██╗██║████╗  ██║██╔══██╗"
echo "  ██╔████╔██║ ╚████╔╝ █████╗  ██║   ██║██████╔╝██║██╔██╗ ██║███████║"
echo "  ██║╚██╔╝██║  ╚██╔╝  ██╔══╝  ██║   ██║██╔══██╗██║██║╚██╗██║██╔══██║"
echo "  ██║ ╚═╝ ██║   ██║   ██║     ╚██████╔╝██║  ██║██║██║ ╚████║██║  ██║"
echo "  ╚═╝     ╚═╝   ╚═╝   ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${CYAN}  One-click installer for AI Agent + Brain System${NC}"
echo ""

# ============================================
# System Check
# ============================================
echo -e "${YELLOW}[1/8] System check...${NC}"

if [[ "$(uname)" != "Linux" ]]; then
    echo -e "${RED}Error: This installer only supports Linux.${NC}"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: Please run as root (sudo ./install.sh)${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ Linux detected${NC}"
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

PACKAGES_TO_INSTALL=""
for pkg in curl wget git python3; do
    if ! command -v $pkg &> /dev/null; then
        PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $pkg"
    else
        echo -e "${GREEN}  ✓ $pkg already installed${NC}"
    fi
done

if [[ -n "$PACKAGES_TO_INSTALL" ]]; then
    apt-get update -qq
    apt-get install -y -qq $PACKAGES_TO_INSTALL > /dev/null 2>&1
    echo -e "${GREEN}  ✓ Installed:$PACKAGES_TO_INSTALL${NC}"
fi

# Node.js
if ! command -v node &> /dev/null; then
    echo -e "${CYAN}  Installing Node.js...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
    apt-get install -y -qq nodejs > /dev/null 2>&1
    echo -e "${GREEN}  ✓ Node.js installed${NC}"
else
    echo -e "${GREEN}  ✓ Node.js already installed${NC}"
fi

if ! command -v npm &> /dev/null; then
    echo -e "${CYAN}  Installing npm...${NC}"
    apt-get install -y -qq npm > /dev/null 2>&1
    echo -e "${GREEN}  ✓ npm installed${NC}"
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
        curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
        if command -v hermes &> /dev/null; then
            echo -e "${GREEN}  ✓ Hermes installed successfully${NC}"
        else
            echo -e "${RED}  ✗ Hermes installation failed${NC}"
            echo -e "${YELLOW}  Try manually: curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash${NC}"
            exit 1
        fi
    fi
else
    if command -v openclaw &> /dev/null; then
        echo -e "${GREEN}  ✓ OpenClaw already installed${NC}"
    else
        echo -e "${CYAN}  Installing OpenClaw via npm...${NC}"
        npm install -g openclaw 2>/dev/null || {
            echo -e "${YELLOW}  npm install failed, trying from source...${NC}"
            cd /tmp
            git clone https://github.com/openclaw/openclaw.git 2>/dev/null || true
            cd openclaw && npm install && npm link
            cd /tmp && rm -rf openclaw
        }
        if command -v openclaw &> /dev/null; then
            echo -e "${GREEN}  ✓ OpenClaw installed successfully${NC}"
        else
            echo -e "${RED}  ✗ OpenClaw installation failed${NC}"
            echo -e "${YELLOW}  Try manually: npm install -g openclaw${NC}"
            exit 1
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
echo -e "${GREEN}  ✓ API Key: ${API_KEY:0:5}...${NC}"
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

echo -e -n "${CYAN}  Enter your Telegram Chat ID (required): ${NC}"
read -r TELEGRAM_CHAT_ID
while [[ -z "$TELEGRAM_CHAT_ID" ]]; do
    echo -e "${RED}  Telegram Chat ID is required!${NC}"
    echo -e -n "${CYAN}  Enter your Telegram Chat ID: ${NC}"
    read -r TELEGRAM_CHAT_ID
done

echo ""
echo -e "${GREEN}  ✓ Bot Token: ${TELEGRAM_BOT_TOKEN:0:5}...${NC}"
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
    hermes config set custom_providers.myfurina.name "Myfurina Provider" 2>&1 || echo -e "${YELLOW}  Warning: provider name${NC}"
    hermes config set custom_providers.myfurina.base_url "$BASE_URL" 2>&1 || echo -e "${YELLOW}  Warning: base_url${NC}"
    hermes config set custom_providers.myfurina.api_key "$API_KEY" 2>&1 || echo -e "${YELLOW}  Warning: api_key${NC}"
    hermes config set custom_providers.myfurina.model "$MODEL_NAME" 2>&1 || echo -e "${YELLOW}  Warning: model${NC}"
    hermes config set main_provider "custom:myfurina" 2>&1 || echo -e "${YELLOW}  Warning: main_provider${NC}"
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

    # Step 3: Configure Telegram (CORRECT: top-level telegram: section)
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
    except:
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
        echo -e "${RED}  ✗ Python YAML config failed${NC}"
        echo -e "${YELLOW}  Manual fix: hermes config edit${NC}"
    fi

    # Step 4: Restrict permissions
    chmod 600 "$HOME/.hermes/config.yaml" 2>/dev/null || true

    # Step 5: Verify
    echo -e "${CYAN}  Verifying...${NC}"
    if grep -q "custom:myfurina" "$HOME/.hermes/config.yaml" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Custom provider verified${NC}"
    else
        echo -e "${YELLOW}  ⚠ Custom provider not in config${NC}"
    fi
    if grep -q "bot_token" "$HOME/.hermes/config.yaml" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Telegram config verified${NC}"
    else
        echo -e "${YELLOW}  ⚠ Telegram config not in config${NC}"
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
    openclaw config patch --file "$OPENCLAW_PATCH" 2>&1 || echo -e "${YELLOW}  Patch warnings (config file already created)${NC}"
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

if [[ "$AGENT_CHOICE" == "1" ]]; then
    cat >> "$INSTALL_DIR/start.sh" << STARTEOF
export OPENAI_API_KEY="$API_KEY"
export OPENAI_BASE_URL="$BASE_URL"
if ! command -v hermes &> /dev/null; then
    echo -e "\${RED}Error: hermes not found\${NC}"; exit 1
fi
if [[ ! -f "\$HOME/.hermes/config.yaml" ]]; then
    echo -e "\${RED}Error: config.yaml not found\${NC}"; exit 1
fi
echo -e "\${CYAN}Starting Hermes gateway...\${NC}"
hermes gateway start
echo -e "\${GREEN}✓ Myfurina is running!\${NC}"
echo -e "  Chat: Telegram | Stop: ~/.superagent/stop.sh"
STARTEOF
else
    cat >> "$INSTALL_DIR/start.sh" << STARTEOF
export OPENAI_API_KEY="$API_KEY"
export OPENAI_BASE_URL="$BASE_URL"
export TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
export TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"
if ! command -v openclaw &> /dev/null; then
    echo -e "\${RED}Error: openclaw not found\${NC}"; exit 1
fi
echo -e "\${CYAN}Starting OpenClaw gateway...\${NC}"
openclaw gateway start
echo -e "\${GREEN}✓ Myfurina is running!\${NC}"
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
