# 🤖 Agent Nexus

A centralized configuration repository for managing AI agent skills and MCP servers cross-platform. This project ensures that **Claude Code**, **Cursor**, and **Google Antigravity** share identical, high-performance developer configurations on any machine.

## 🚀 Overview

This repository acts as a single point of truth for your agentic development environment. It uses [Agent Package Manager (APM)](https://github.com/microsoft/apm) and the [skills CLI](https://github.com/vercel-labs/skills) to resolve dependencies and deploy them globally via symlinks.

### Key Platforms Supported
- **Claude Code**: Industry-leading agentic terminal interface.
- **Cursor**: The AI-first code editor.
- **Google Antigravity**: Advanced agentic coding assistant.

## 🛠️ Getting Started

### Prerequisites
- **Python 3.8+** (for `apm-cli`)
- **Node.js 18+** (for MCP servers and `skills`)
- **Git**

### Installation & Deployment

```bash
# 1. Clone the repository
git clone https://github.com/fantasy-cc/agent-nexus.git ~/Project/agent-nexus
cd ~/Project/agent-nexus

# 2. Install APM CLI (if not already installed)
pip install apm-cli

# 3. Deploy everything
./deploy.sh
```

The `deploy.sh` script automates the entire setup:
1. Runs `apm install` to fetch remote skills.
2. Syncs MCP server configurations to **Claude** (`~/.claude.json`), **Cursor** (`~/.cursor/mcp.json`), and **Antigravity** (`~/.gemini/antigravity/mcp_config.json`). Removes the repo-local `.cursor/mcp.json` after APM so Cursor does not register MCP servers twice.
3. Checks for the Xiaohongshu Go binary in `bin/` and ensures the optional `xiaohongshu-mcp` HTTP entry points at `http://localhost:18060/mcp` in Claude and Cursor.
4. Creates symlinks from local modules to global IDE skill directories.
5. Installs global packages via the skills CLI (`find-skills`).

## 📦 Managed Assets

### 🧠 Installed Skills
| Name | Source | Description |
|------|--------|-------------|
| `context-harness` | Local | Maintains project context (AGENTS.md, PLANS.md, etc.) |
| `obra/superpowers` | GitHub | Advanced dev methodology (TDD, brainstorming, worktrees) |
| `find-skills` | skills CLI | Discovery tool for the agent skills ecosystem |

### 🔌 MCP Servers
Servers listed in `apm.yml` are merged into your global MCP configs when you run `./deploy.sh`:
- **`sequential-thinking`**: Structured reasoning for complex problem-solving.
- **`github-mcp`**: Full GitHub integration (issues, PRs, repositories).
- **`playwright`**: Browser automation via the official Playwright MCP package.
- **`context7`**: Real-time documentation and code example retrieval.
- **`nitan-mcp`**: Community MCP (`@nitansde/mcp`).
- **`notion-mcp`**: Official Notion integration.

**Xiaohongshu (optional):** Not declared in `apm.yml`. Uses [xpzouying/xiaohongshu-mcp](https://github.com/xpzouying/xiaohongshu-mcp) Go binary in `bin/`. Run `scripts/xhs-relogin` once to authenticate, then `scripts/xhs-start` to start the server (HTTP on `localhost:18060`). `deploy.sh` ensures the HTTP MCP entry exists in both Claude Code and Cursor. The generated `cookies.json` is local session state and should never be committed.

## 🏗️ Project Structure

- `apm.yml` — The heart of the configuration. Define your skills and MCPs here.
- `deploy.sh` — The deployment engine that syncs this repo to your system.
- `bin/` — Pre-built Go binaries for Xiaohongshu MCP.
- `scripts/` — Helper scripts (`xhs-start`, `xhs-relogin`) for Xiaohongshu MCP management.
- `context-harness/` — Local skill definitions for project management.
- `AGENTS.md` — Core AI context for this repository.
- `PLANS.md` — Active development roadmap.
- `FINDINGS.md` — Research logs and discovery notes.
- `EVALUATION.md` — Verification contracts and evaluation log.

## 🧪 Development

To add a new skill to your toolkit:
1. Create a subfolder with a `SKILL.md` (check `context-harness/` for reference).
2. Add the dependency to `apm.yml`.
3. Run `./deploy.sh` to update your global agent environment.

---
*Maintained by lfan. Powered by APM.*
