#!/bin/bash

# ============================================
# SUPERAGENT Installer
# One-click setup for AI Agent + 9Router
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

  Elite AI Agent Installer v1.0
EOF
echo -e "${NC}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Welcome to SUPERAGENT Installer!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# ============================================
# System Check
# ============================================
echo -e "${YELLOW}[1/6] Checking system...${NC}"

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
echo -e "${YELLOW}[2/6] Checking dependencies...${NC}"

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
# Install 9Router
# ============================================
echo -e "${YELLOW}[3/6] Installing 9Router (AI Gateway)...${NC}"

# Check if 9Router is already installed
if command -v 9router &> /dev/null; then
    echo -e "${GREEN}✓ 9Router already installed${NC}"
else
    # Install 9Router globally
    npm install -g 9router || {
        echo -e "${RED}Error: 9Router installation failed${NC}"
        exit 1
    }
    echo -e "${GREEN}✓ 9Router installed${NC}"
fi
echo ""

# ============================================
# Install OpenClaw/Hermes
# ============================================
echo -e "${YELLOW}[4/6] Checking agent framework...${NC}"

# Create installation directory
INSTALL_DIR="$HOME/.superagent"
mkdir -p "$INSTALL_DIR"

# Check for existing agent frameworks
if command -v openclaw &> /dev/null; then
    echo -e "${GREEN}✓ OpenClaw found${NC}"
    AGENT_TYPE="openclaw"
elif command -v hermes &> /dev/null; then
    echo -e "${GREEN}✓ Hermes found${NC}"
    AGENT_TYPE="hermes"
else
    echo -e "${YELLOW}Note: No agent framework found. Installing OpenClaw...${NC}"
    npm install -g openclaw 2>/dev/null || {
        echo -e "${YELLOW}Note: OpenClaw not available via npm, using manual setup${NC}"
        AGENT_TYPE="manual"
    }
    if command -v openclaw &> /dev/null; then
        AGENT_TYPE="openclaw"
    else
        AGENT_TYPE="manual"
    fi
fi

echo -e "${GREEN}✓ Agent framework ready ($AGENT_TYPE)${NC}"
echo ""

# ============================================
# Setup SUPERAGENT Brain
# ============================================
echo -e "${YELLOW}[5/6] Setting up SUPERAGENT brain...${NC}"

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

# Create USER.md template
cat > "$BRAIN_DIR/USER.md" << 'EOF'
# USER.md — Owner Profile

**Name**: [Your Name]
**Username**: [Your Username]
**Language**: Bahasa Indonesia (casual)
**Preferences**: [Your preferences here]

---

## Communication Style
- Direct and to the point
- No unnecessary formalities
- Technical terms in English

## Projects
- [List your projects here]

## Goals
- [Your goals here]
EOF
echo -e "${GREEN}✓ USER.md created${NC}"

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

## API Gateway
- 9Router: http://localhost:20128/v1
- Model: [configured during setup]

## Deployment
- Vercel, Docker, VPS
EOF
echo -e "${GREEN}✓ TOOLS.md created${NC}"

echo -e "${GREEN}✓ SUPERAGENT brain configured${NC}"
echo ""

# ============================================
# Configure API & Model
# ============================================
echo -e "${YELLOW}[6/6] Configuring API & Model...${NC}"
echo ""

# Get API Key
echo -e "${CYAN}Enter your API Key:${NC}"
read -r API_KEY

# Get Base URL
echo -e "${CYAN}Enter Base URL (default: http://localhost:20128/v1):${NC}"
read -r BASE_URL
BASE_URL=${BASE_URL:-"http://localhost:20128/v1"}

# Get Model
echo -e "${CYAN}Enter Model name (e.g., claude-sonnet-4, gpt-4o, deepseek-chat):${NC}"
read -r MODEL_NAME

# Create config file
cat > "$INSTALL_DIR/config.env" << EOF
# SUPERAGENT Configuration
API_KEY=$API_KEY
BASE_URL=$BASE_URL
MODEL=$MODEL_NAME

# 9Router Settings
NINE_ROUTER_PORT=20128
NINE_ROUTER_URL=http://localhost:20128/v1
EOF
echo -e "${GREEN}✓ Configuration saved${NC}"

# Update TOOLS.md with actual config
sed -i "s|http://localhost:20128/v1|$BASE_URL|g" "$BRAIN_DIR/TOOLS.md"
sed -i "s|\[configured during setup\]|$MODEL_NAME|g" "$BRAIN_DIR/TOOLS.md"

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

# Start 9Router in background
echo "Starting 9Router on port $NINE_ROUTER_PORT..."
9router &
NINE_ROUTER_PID=$!

# Wait for 9Router to be ready
sleep 3

# Check if 9Router is running
if curl -s http://localhost:$NINE_ROUTER_PORT/health > /dev/null 2>&1; then
    echo "✓ 9Router started (PID: $NINE_ROUTER_PID)"
else
    echo "⚠ 9Router may not be fully started yet"
fi

echo "Dashboard: http://localhost:$NINE_ROUTER_PORT"
echo ""

# Export environment variables
export API_KEY
export BASE_URL
export MODEL

echo "Configuration:"
echo "  API Key: ${API_KEY:0:10}..."
echo "  Base URL: $BASE_URL"
echo "  Model: $MODEL"
echo ""

# Start agent (if available)
if command -v openclaw &> /dev/null; then
    echo "Starting OpenClaw..."
    openclaw start
elif command -v hermes &> /dev/null; then
    echo "Starting Hermes..."
    hermes gateway start
else
    echo "Agent framework ready. Use 'openclaw' or 'hermes' commands."
fi

echo ""
echo "SUPERAGENT is ready! 🔥"
echo "Access 9Router dashboard: http://localhost:$NINE_ROUTER_PORT"
STARTUP

chmod +x "$INSTALL_DIR/start.sh"
echo -e "${GREEN}✓ Start script created${NC}"

# Create stop script
cat > "$INSTALL_DIR/stop.sh" << 'STOP'
#!/bin/bash

echo "Stopping SUPERAGENT..."

# Stop 9Router
pkill -f "9router" 2>/dev/null || true

# Stop agent
if command -v openclaw &> /dev/null; then
    openclaw stop 2>/dev/null || true
elif command -v hermes &> /dev/null; then
    hermes gateway stop 2>/dev/null || true
fi

echo "✓ SUPERAGENT stopped."
STOP

chmod +x "$INSTALL_DIR/stop.sh"
echo -e "${GREEN}✓ Stop script created${NC}"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Installation Complete! 🔥${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}Installation Directory:${NC} $INSTALL_DIR"
echo ""
echo -e "${CYAN}Quick Start:${NC}"
echo -e "  ${GREEN}~/.superagent/start.sh${NC}    # Start 9Router + Agent"
echo -e "  ${GREEN}~/.superagent/stop.sh${NC}     # Stop all services"
echo ""
echo -e "${CYAN}9Router Dashboard:${NC} http://localhost:20128"
echo ""
echo -e "${CYAN}Configuration:${NC} $INSTALL_DIR/config.env"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Run ${GREEN}~/.superagent/start.sh${NC} to start"
echo -e "  2. Open ${GREEN}http://localhost:20128${NC} for 9Router dashboard"
echo -e "  3. Edit ${GREEN}$BRAIN_DIR/USER.md${NC} with your profile"
echo -e "  4. Start chatting with your AI agent!"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${CYAN}  SUPERAGENT — Built for execution. 🔥${NC}"
echo -e "${BLUE}========================================${NC}"
