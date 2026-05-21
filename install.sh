#!/bin/bash

# ============================================
# SUPERAGENT Installer
# One-click setup for AI Agent + OpenClaw
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logo
echo -e "${CYAN}"
cat << "EOF"
  ____  _   _ ____  _____     _    ____ ___ _   _  ____
 / ___|| | | |  _ \| ____|   / \  |  _ \_ _| \ | |/ ___|
 \___ \| | | | |_) |  _|    / _ \ | |_) | ||  \| | |  _
  ___) | |_| |  __/| |___  / ___ \|  __/| || |\  | |_| |
 |____/ \___/|_|   |_____|_/   \_\_|  |___|_| \_|\____|

  Elite AI Agent Installer v2.0
EOF
echo -e "${NC}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Welcome to SUPERAGENT Installer!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ============================================
# System Check
# ============================================
echo -e "${YELLOW}[1/5] Checking system...${NC}"

# Check OS
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}Error: This installer only supports Linux.${NC}"
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run as root (sudo ./install.sh)${NC}"
    exit 1
fi

echo -e "${GREEN}✓ System check passed${NC}"
echo ""

# ============================================
# Install Dependencies
# ============================================
echo -e "${YELLOW}[2/5] Checking dependencies...${NC}"

# Update package list
apt-get update -qq

# Check and install essential packages
PACKAGES_TO_INSTALL=""

for pkg in curl wget git; do
    if ! command -v $pkg &> /dev/null; then
        PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $pkg"
    else
        echo -e "${GREEN}✓ $pkg already installed${NC}"
    fi
done

# Check Node.js
if ! command -v node &> /dev/null; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL nodejs"
else
    echo -e "${GREEN}✓ Node.js already installed ($(node --version))${NC}"
fi

# Check npm
if ! command -v npm &> /dev/null; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL npm"
else
    echo -e "${GREEN}✓ npm already installed ($(npm --version))${NC}"
fi

# Install missing packages
if [ -n "$PACKAGES_TO_INSTALL" ]; then
    echo -e "${YELLOW}Installing:$PACKAGES_TO_INSTALL${NC}"
    apt-get install -y $PACKAGES_TO_INSTALL || {
        echo -e "${YELLOW}Warning: Some packages failed to install, but continuing...${NC}"
    }
fi

echo -e "${GREEN}✓ Dependencies ready${NC}"
echo ""

# ============================================
# Install OpenClaw
# ============================================
echo -e "${YELLOW}[3/5] Installing OpenClaw...${NC}"

# Create installation directory
INSTALL_DIR="$HOME/.superagent"
mkdir -p "$INSTALL_DIR"

# Check if OpenClaw is already installed
if command -v openclaw &> /dev/null; then
    echo -e "${GREEN}✓ OpenClaw already installed ($(openclaw --version 2>/dev/null || echo 'version unknown'))${NC}"
    AGENT_TYPE="openclaw"
else
    echo -e "${YELLOW}Installing OpenClaw...${NC}"
    npm install -g openclaw 2>/dev/null || {
        echo -e "${RED}Error: OpenClaw installation failed${NC}"
        echo -e "${YELLOW}Trying alternative installation method...${NC}"
        # Clone from GitHub
        git clone https://github.com/openclaw/openclaw.git "$INSTALL_DIR/openclaw" 2>/dev/null || {
            echo -e "${RED}Error: Could not install OpenClaw${NC}"
            exit 1
        }
    }
    
    # Verify installation
    if command -v openclaw &> /dev/null; then
        echo -e "${GREEN}✓ OpenClaw installed successfully${NC}"
        AGENT_TYPE="openclaw"
    else
        echo -e "${RED}Error: OpenClaw not found after installation${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Agent framework ready ($AGENT_TYPE)${NC}"
echo ""

# ============================================
# Setup SUPERAGENT Brain
# ============================================
echo -e "${YELLOW}[4/5] Setting up SUPERAGENT brain...${NC}"

# Copy brain files
BRAIN_DIR="$INSTALL_DIR/brain"
mkdir -p "$BRAIN_DIR"
mkdir -p "$BRAIN_DIR/skills"
mkdir -p "$BRAIN_DIR/memory"

# Copy SOUL.md
if [ -f "brain/SOUL.md" ]; then
    cp brain/SOUL.md "$BRAIN_DIR/SOUL.md"
    echo -e "${GREEN}✓ SOUL.md copied${NC}"
else
    echo -e "${RED}Error: brain/SOUL.md not found${NC}"
    exit 1
fi

# Copy skill files (if they exist)
if [ -d "skills" ]; then
    cp -r skills/* "$BRAIN_DIR/skills/" 2>/dev/null || true
    echo -e "${GREEN}✓ Skills copied${NC}"
fi

# Create AGENTS.md
cat > "$BRAIN_DIR/AGENTS.md" << 'EOF'
# AGENTS.md — Core Brain & Router
# Auto-injected every session.

---

## ALWAYS LOAD ON SESSION START

Read brain/SOUL.md — this is the constitution.
Read brain/MEMORY.md for long-term context.
Read brain/memory/[today's date].md if exists.

---

## SKILL ROUTER

Match user intent to skill modules. Load on demand.

```
monetize / business / income / sell / cuan  → skills/m1.md
server / VPS / deploy / linux / docker     → skills/m2.md
content / caption / viral / script         → skills/m3.md
bot / automation / cron / webhook          → skills/m4.md
data / spreadsheet / analytics / report    → skills/m5.md
API / integration / REST / SDK             → skills/m6.md
AI / prompt / agent / LLM / model         → skills/m7.md
file / PDF / DOCX / generate / export     → skills/m8.md
website / landing / frontend / React       → skills/m9.md
audit / improve / review agent             → skills/x1.md
complex / strategy / multi-step            → skills/x2.md
error / bug / not working / debug          → skills/x3.md
```

---

## CORE RULES

**R1 — Execute first**
Deliver working output first. Explain after.

**R2 — Never dead-end**
Cannot do X → explain why → offer alternative.

**R3 — Memory write triggers**
Write to memory when: decision made, preference revealed, project context established.

**R4 — Output format**
[OUTPUT] → deliverable
[NEXT STEP] → immediate action
[🔧 UPGRADE] → one line improvement (when meaningful)
EOF
echo -e "${GREEN}✓ AGENTS.md created${NC}"

# Create MEMORY.md
cat > "$BRAIN_DIR/MEMORY.md" << 'EOF'
# MEMORY.md — Long-term Context

---

## Environment
- OS: Linux
- Installed: [tools will be logged here]

## Preferences
- [User preferences will be logged here]

## Lessons Learned
- [Important lessons will be logged here]
EOF
echo -e "${GREEN}✓ MEMORY.md created${NC}"

# Create TOOLS.md
cat > "$BRAIN_DIR/TOOLS.md" << 'EOF'
# TOOLS.md — Available Tools

## Core Tools
- Terminal (bash, npm, git, docker)
- File System (read, write, edit)
- Web (browser, HTTP, scraping)
- GitHub (repos, PR, issues)

## AI Provider
- Provider: [configured during setup]
- Model: [configured during setup]
- Base URL: [configured during setup]

## Messaging
- Telegram Bot: [configured if provided]
- Chat ID: [configured if provided]

## Deployment
- Vercel, Docker, VPS
EOF
echo -e "${GREEN}✓ TOOLS.md created${NC}"

echo -e "${GREEN}✓ SUPERAGENT brain configured${NC}"
echo ""

# ============================================
# Configure API & Model
# ============================================
echo -e "${YELLOW}[5/5] Configuring API & Model...${NC}"
echo ""

# Get API Key
echo -e "${CYAN}Enter your API Key:${NC}"
read -r API_KEY

# Get Base URL
echo -e "${CYAN}Enter Base URL (e.g., https://api.openai.com/v1, https://openrouter.ai/api/v1):${NC}"
read -r BASE_URL
BASE_URL=${BASE_URL:-"https://api.openai.com/v1"}

# Get Model
echo -e "${CYAN}Enter Model name (e.g., gpt-4o, claude-sonnet-4, deepseek-chat):${NC}"
read -r MODEL_NAME

# Get Telegram Bot Token (optional)
echo -e "${CYAN}Enter Telegram Bot Token (optional, press Enter to skip):${NC}"
read -r TELEGRAM_BOT_TOKEN

# Get Telegram Chat ID (optional)
TELEGRAM_CHAT_ID=""
if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
    echo -e "${CYAN}Enter your Telegram Chat ID (for notifications):${NC}"
    read -r TELEGRAM_CHAT_ID
fi

# Create config file for SUPERAGENT
cat > "$INSTALL_DIR/config.env" << EOF
# SUPERAGENT Configuration
API_KEY=$API_KEY
BASE_URL=$BASE_URL
MODEL=$MODEL_NAME

# Telegram Bot (optional)
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID
EOF
echo -e "${GREEN}✓ Configuration saved${NC}"

# ============================================
# Configure OpenClaw directly
# ============================================
echo -e "${YELLOW}Configuring OpenClaw with your API settings...${NC}"

# Set OpenClaw provider config
openclaw config set models.providers.custom.baseUrl "$BASE_URL" 2>/dev/null || true
openclaw config set models.providers.custom.apiKey "$API_KEY" 2>/dev/null || true

# Set default model
openclaw config set models.defaults.model "$MODEL_NAME" 2>/dev/null || true

echo -e "${GREEN}✓ OpenClaw configured${NC}"

# Update TOOLS.md with actual config
sed -i "s|\[configured during setup\]|$MODEL_NAME|g" "$BRAIN_DIR/TOOLS.md"
sed -i "s|\[configured if provided\]|✓ Configured|g" "$BRAIN_DIR/TOOLS.md" 2>/dev/null || true

# Update provider info in TOOLS.md
PROVIDER_NAME=$(echo "$BASE_URL" | sed -E 's|https?://([^/]+).*|\1|')
sed -i "s|Provider: \[configured during setup\]|Provider: Custom ($PROVIDER_NAME)|g" "$BRAIN_DIR/TOOLS.md"
sed -i "s|Base URL: \[configured during setup\]|Base URL: $BASE_URL|g" "$BRAIN_DIR/TOOLS.md"

# Update Telegram config in TOOLS.md
if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
    sed -i "s|\[configured if provided\]|✓ Configured|g" "$BRAIN_DIR/TOOLS.md"
else
    sed -i "s|\[configured if provided\]|Not configured|g" "$BRAIN_DIR/TOOLS.md"
fi

echo ""

# ============================================
# Setup User Profile
# ============================================
echo -e "${YELLOW}Setting up your profile...${NC}"
echo ""

# Get user info
echo -e "${CYAN}Enter your name:${NC}"
read -r USER_NAME

echo -e "${CYAN}Enter your username (for social media, etc):${NC}"
read -r USER_USERNAME

echo -e "${CYAN}Enter your preferred language (default: Bahasa Indonesia):${NC}"
read -r USER_LANG
USER_LANG=${USER_LANG:-"Bahasa Indonesia"}

echo -e "${CYAN}Enter your communication style (e.g., direct, casual, formal):${NC}"
read -r USER_STYLE
USER_STYLE=${USER_STYLE:-"direct and casual"}

echo -e "${CYAN}Enter your main projects (comma separated, or press enter to skip):${NC}"
read -r USER_PROJECTS

echo -e "${CYAN}Enter your main goals (comma separated, or press enter to skip):${NC}"
read -r USER_GOALS

# Create USER.md
cat > "$BRAIN_DIR/USER.md" << EOF
# USER.md — Owner Profile

**Name**: $USER_NAME
**Username**: $USER_USERNAME
**Language**: $USER_LANG
**Style**: $USER_STYLE

---

## Communication Style
- $USER_STYLE
- Technical terms in English

## Projects
$(if [ -n "$USER_PROJECTS" ]; then
    echo "$USER_PROJECTS" | tr ',' '\n' | sed 's/^/- /'
else
    echo "- [Add your projects here]"
fi)

## Goals
$(if [ -n "$USER_GOALS" ]; then
    echo "$USER_GOALS" | tr ',' '\n' | sed 's/^/- /'
else
    echo "- [Add your goals here]"
fi)
EOF
echo -e "${GREEN}✓ Profile created${NC}"

# ============================================
# Update SOUL.md with user's language
# ============================================
echo -e "${YELLOW}Updating SOUL.md with your language preference...${NC}"

# Update Language Rules in SOUL.md
sed -i "s|- \*\*Chat\*\*: \[USER_LANGUAGE\]|- **Chat**: $USER_LANG|g" "$BRAIN_DIR/SOUL.md"

# Update Identity section based on language
if [ "$USER_LANG" = "Bahasa Indonesia" ]; then
    sed -i 's|- Use appropriate register for the specified language.|- Use casual register (aku/kamu) for Indonesian users.|g' "$BRAIN_DIR/SOUL.md"
else
    sed -i "s|- Use appropriate register for the specified language.|- Use appropriate register for $USER_LANG users.|g" "$BRAIN_DIR/SOUL.md"
fi

echo -e "${GREEN}✓ SOUL.md updated with $USER_LANG${NC}"

echo ""

# ============================================
# Create startup script
# ============================================
cat > "$INSTALL_DIR/start.sh" << 'STARTUP'
#!/bin/bash

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.env"

echo "Starting SUPERAGENT..."
echo ""

# Export environment variables for OpenClaw
export OPENAI_API_KEY="$API_KEY"
export OPENAI_BASE_URL="$BASE_URL"

echo "Configuration:"
echo "  API Key: ${API_KEY:0:10}..."
echo "  Base URL: $BASE_URL"
echo "  Model: $MODEL"
echo ""

# Start OpenClaw
if command -v openclaw &> /dev/null; then
    echo "Starting OpenClaw gateway..."
    openclaw gateway start
else
    echo "Error: OpenClaw not found!"
    exit 1
fi

echo ""
echo "SUPERAGENT is ready! 🔥"
STARTUP

chmod +x "$INSTALL_DIR/start.sh"
echo -e "${GREEN}✓ Start script created${NC}"

# Create stop script
cat > "$INSTALL_DIR/stop.sh" << 'STOP'
#!/bin/bash

echo "Stopping SUPERAGENT..."

# Stop OpenClaw
if command -v openclaw &> /dev/null; then
    openclaw gateway stop 2>/dev/null || true
else
    echo "Warning: OpenClaw not found"
fi

echo "✓ SUPERAGENT stopped."
STOP

chmod +x "$INSTALL_DIR/stop.sh"
echo -e "${GREEN}✓ Stop script created${NC}"

echo ""

# ============================================
# Auto-Start Services
# ============================================
echo -e "${YELLOW}Starting services...${NC}"
echo ""

# Run start script
"$INSTALL_DIR/start.sh"

echo ""

# ============================================
# Final Summary
# ============================================
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Installation Complete! 🔥${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}Installation Directory:${NC} $INSTALL_DIR"
echo ""
echo -e "${CYAN}Your Profile:${NC}"
echo -e "  Name: $USER_NAME"
echo -e "  Username: $USER_USERNAME"
echo -e "  Language: $USER_LANG"
echo -e "  Style: $USER_STYLE"
echo ""
echo -e "${CYAN}Configuration:${NC}"
echo -e "  API Key: ${API_KEY:0:10}..."
echo -e "  Base URL: $BASE_URL"
echo -e "  Model: $MODEL_NAME"
echo ""
echo -e "${CYAN}Services:${NC}"
echo -e "  Agent: $AGENT_TYPE"
echo -e "  Gateway: OpenClaw"
echo ""
echo -e "${CYAN}Quick Commands:${NC}"
echo -e "  ${GREEN}~/.superagent/start.sh${NC}    # Start services"
echo -e "  ${GREEN}~/.superagent/stop.sh${NC}     # Stop services"
echo -e "  ${GREEN}nano ~/.superagent/brain/USER.md${NC}  # Edit profile"
echo ""
echo -e "${YELLOW}What's Next:${NC}"
echo -e "  1. Start chatting with your AI agent!"
echo -e "  2. Edit ${GREEN}~/.superagent/brain/USER.md${NC} to update your profile"
echo -e "  3. Add skills to ${GREEN}~/.superagent/brain/skills/${NC}"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}  SUPERAGENT — Built for execution. 🔥${NC}"
echo -e "${BLUE}========================================${NC}"
