# Myfurina

<div align="center">

**One-click installer for AI Agent + OpenClaw**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)]()
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)]()

</div>

---

## What is Myfurina?

Myfurina is an **elite execution agent** that combines:

- 🧠 **OpenClaw** — AI agent framework
- 📝 **SOUL.md** — Comprehensive agent constitution
- 🎯 **Skill System** — Modular capabilities (m1-m9, x1-x3)
- 📱 **Telegram Bot** — Chat with your agent via Telegram

## Features

- ✅ **One-click installation** — Just run the script
- ✅ **Direct OpenClaw config** — API key, base URL, model langsung
- ✅ **Telegram integration** — Bot token & chat ID required
- ✅ **Complete brain system** — SOUL.md, skills, memory
- ✅ **Multi-provider support** — OpenAI, Claude, Gemini, DeepSeek, dll
- ✅ **Custom language** — Bisa pakai bahasa apapun
- ✅ **Modular skills** — Business, VPS, content, automation, dll

## Quick Start

### Prerequisites

- Linux (Ubuntu/Debian recommended)
- Root access (sudo)
- Internet connection
- Telegram Bot Token & Chat ID

### Installation

```bash
# Clone the repository
git clone https://github.com/galinaplinoel-stack/Myfurina.git
cd Myfurina

# Make installer executable
chmod +x install.sh

# Run installer
sudo ./install.sh
```

### What Happens During Installation?

1. **System check** — Verifies Linux and root access
2. **Install dependencies** — Node.js, npm, curl, git
3. **Install OpenClaw** — AI agent framework
4. **Setup brain** — SOUL.md, skills, memory system
5. **Configure API & Telegram** — Asks for:
   - API Key
   - Base URL (e.g., `https://api.openai.com/v1`)
   - Model name (e.g., `gpt-4o`)
   - **Telegram Bot Token** (required)
   - **Telegram Chat ID** (required)
   - User profile (name, username, language, style)

## After Installation

### Start Myfurina

```bash
~/.superagent/start.sh
```

This will:
- Export API key and base URL
- Start OpenClaw gateway

### Stop Myfurina

```bash
~/.superagent/stop.sh
```

### Edit Your Profile

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
| `BASE_URL` | API endpoint | `https://api.openai.com/v1` |
| `MODEL` | Model name | `gpt-4o` |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token | `123456:ABC-DEF` |
| `TELEGRAM_CHAT_ID` | Telegram chat ID | `123456789` |

### Supported Providers

| Provider | Base URL | Models |
|----------|----------|--------|
| **OpenAI** | `https://api.openai.com/v1` | GPT-4o, GPT-4, GPT-3.5 |
| **Anthropic** | `https://api.anthropic.com/v1` | Claude 3.5, Claude 3 |
| **OpenRouter** | `https://openrouter.ai/api/v1` | 100+ models |
| **DeepSeek** | `https://api.deepseek.com/v1` | DeepSeek Chat |
| **Groq** | `https://api.groq.com/v1` | Llama, Mixtral |
| **Local** | `http://localhost:11434/v1` | Ollama models |

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

### Edit SOUL.md
```bash
nano ~/.superagent/brain/SOUL.md
```

### Add Custom Skill
```bash
nano ~/.superagent/brain/skills/m10.md
```

## Troubleshooting

### Agent not responding
```bash
# Check configuration
cat ~/.superagent/config.env

# Check OpenClaw status
openclaw gateway status

# Restart services
~/.superagent/stop.sh
~/.superagent/start.sh
```

### API Key issues
```bash
# Edit configuration
nano ~/.superagent/config.env

# Reconfigure OpenClaw
openclaw config set models.providers.custom.apiKey "your-new-key"

# Restart services
~/.superagent/stop.sh
~/.superagent/start.sh
```

### Telegram Bot not working
```bash
# Check bot token
cat ~/.superagent/config.env | grep TELEGRAM

# Test bot connection
curl "https://api.telegram.org/bot<YOUR_TOKEN>/getMe"
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

### Switch Provider

Edit config and reconfigure:
```bash
# Edit config
nano ~/.superagent/config.env

# Update OpenClaw
openclaw config set models.providers.custom.baseUrl "https://new-provider.com/v1"
openclaw config set models.providers.custom.apiKey "new-api-key"
openclaw config set models.defaults.model "new-model-name"

# Restart
~/.superagent/stop.sh
~/.superagent/start.sh
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

**Myfurina — Built for execution. 🔥**

[GitHub](https://github.com/galinaplinoel-stack/Myfurina) • [Issues](https://github.com/galinaplinoel-stack/Myfurina/issues)

</div>
