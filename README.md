# SUPERAGENT Installer

<div align="center">

**One-click installer for AI Agent + 9Router Gateway**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)]()
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)]()

</div>

---

## What is SUPERAGENT?

SUPERAGENT is an **elite execution agent** that combines:

- 🧠 **OpenClaw** — AI OpenClaw
- 🚀 **9Router** — FREE AI gateway with 40+ providers
- 📝 **SOUL.md** — Comprehensive agent constitution
- 🎯 **Skill System** — Modular capabilities (m1-m9, x1-x3)

## Features

- ✅ **One-click installation** — Just run the script
- ✅ **9Router integration** — FREE AI models, auto-fallback
- ✅ **Complete brain system** — SOUL.md, skills, memory
- ✅ **Multi-provider support** — Claude, GPT, Gemini, DeepSeek, dll
- ✅ **Indonesian language** — Casual "aku/kamu" register
- ✅ **Modular skills** — Business, VPS, content, automation, dll

## Quick Start

### Prerequisites

- Linux (Ubuntu/Debian recommended)
- Root access (sudo)
- Internet connection

### Installation

```bash
# Clone the repository
git clone https://github.com/galinaplinoel-stack/superagent-installer.git
cd superagent-installer

# Make installer executable
chmod +x install.sh

# Run installer
sudo ./install.sh
```

### What Happens During Installation?

1. **System check** — Verifies Linux and root access
2. **Install dependencies** — Node.js, npm, curl, git
3. **Install 9Router** — AI gateway (npm install -g 9router)
4. **Install OpenClaw** — OpenClaw
5. **Setup brain** — SOUL.md, skills, memory system
6. **Configure API** — Asks for API key, base URL, model

## After Installation

### Start SUPERAGENT

```bash
~/.superagent/start.sh
```

This will:
- Start 9Router on port 20128
- Load your configuration
- Start the OpenClaw

### Access 9Router Dashboard

Open your browser and go to:
```
http://localhost:20128
```

### Edit Your Profile

Edit the user profile:
```bash
nano ~/.superagent/brain/USER.md
```

## Configuration

The installer creates a config file at:
```
~/.superagent/config.env
```

### Configuration Options

| Variable | Description | Example |
|----------|-------------|---------|
| `API_KEY` | Your API key | `sk-ant-...` |
| `BASE_URL` | API endpoint | `http://localhost:20128/v1` |
| `MODEL` | Model name | `claude-sonnet-4` |

### Supported Models

| Provider | Models | Free? |
|----------|--------|-------|
| **Kiro AI** | Claude unlimited | ✅ FREE |
| **OpenCode Free** | Various models | ✅ FREE |
| **Anthropic** | Claude 3.5, Claude 4 | ❌ Paid |
| **OpenAI** | GPT-4o, GPT-5 | ❌ Paid |
| **DeepSeek** | DeepSeek Chat | ❌ Cheap |
| **Groq** | Llama, Mixtral | ❌ Fast |

## Brain Structure

```
~/.superagent/brain/
├── SOUL.md          # Agent constitution
├── AGENTS.md        # Core brain & router
├── USER.md          # Your profile
├── MEMORY.md        # Long-term context
├── TOOLS.md         # Available tools
├── skills/
│   ├── m0.md        # Skill registry
│   ├── m1.md        # Monetization
│   ├── m2.md        # VPS & DevOps
│   ├── m3.md        # Content creation
│   ├── m4.md        # Automation
│   ├── m5.md        # Data & analytics
│   ├── m6.md        # API integration
│   ├── m7.md        # AI & prompts
│   ├── m8.md        # File production
│   ├── m9.md        # Web & frontend
│   ├── x1.md        # Self-improvement
│   ├── x2.md        # Deep thinking
│   └── x3.md        # Debug & error
└── memory/
    └── [date].md    # Daily logs
```

## Skill Modules

| ID | Name | Trigger Keywords |
|----|------|-----------------|
| **m1** | Monetization | business, income, sell, cuan |
| **m2** | VPS & DevOps | server, deploy, linux, docker |
| **m3** | Content | content, caption, viral, script |
| **m4** | Automation | bot, automation, cron, webhook |
| **m5** | Data | data, spreadsheet, analytics |
| **m6** | API | API, integration, REST, SDK |
| **m7** | AI | AI, prompt, agent, LLM |
| **m8** | Files | file, PDF, DOCX, generate |
| **m9** | Web | website, landing, frontend |
| **x1** | Audit | audit, improve, review |
| **x2** | Strategy | complex, strategy, multi-step |
| **x3** | Debug | error, bug, debug |

## Commands

### Start Services
```bash
~/.superagent/start.sh
```

### Stop Services
```bash
~/.superagent/stop.sh
```

### View Configuration
```bash
cat ~/.superagent/config.env
```

### Edit Profile
```bash
nano ~/.superagent/brain/USER.md
```

### View Memory
```bash
cat ~/.superagent/brain/MEMORY.md
```

## Troubleshooting

### 9Router won't start
```bash
# Check if port is in use
lsof -i :20128

# Kill existing process
pkill -f 9router

# Restart
~/.superagent/start.sh
```

### Agent not responding
```bash
# Check 9Router status
curl http://localhost:20128/health

# Check configuration
cat ~/.superagent/config.env

# Restart services
~/.superagent/stop.sh
~/.superagent/start.sh
```

### API Key issues
```bash
# Edit configuration
nano ~/.superagent/config.env

# Restart services
~/.superagent/stop.sh
~/.superagent/start.sh
```

## Advanced Usage

### Custom Skills

Add new skills to:
```
~/.superagent/brain/skills/
```

Follow the format:
```markdown
# m10 — [Skill Name]
---
## Operator Profile
[Description]

## [Main Section]
[Content]

## Constraints
- [Rules]
```

### Multiple Providers

9Router supports multiple providers. Configure in dashboard:
```
http://localhost:20128/dashboard
```

### Memory Management

- **Session memory**: Automatic daily logs
- **Long-term memory**: Edit `MEMORY.md` manually
- **Cleanup**: Review and clean memory periodically

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License

---

<div align="center">

**SUPERAGENT — Built for execution. 🔥**

[GitHub](https://github.com/galinaplinoel-stack/superagent-installer) • [Issues](https://github.com/galinaplinoel-stack/superagent-installer/issues)

</div>
