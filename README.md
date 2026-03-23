# agent-skill

A curated collection of AI agent skills and MCP servers — centrally managed and globally deployed to all local IDEs via APM and the skills CLI.

## Getting Started

### Prerequisites
- Python 3.8+ (for installing APM)
- Node.js 18+ (for MCP servers and skills CLI)
- Git
- Access to Claude Code, Cursor, or Google Antigravity

### Installation

This repository uses [Agent Package Manager (APM)](https://github.com/microsoft/apm) and the [skills CLI](https://github.com/vercel-labs/skills) to manage dependencies.

```bash
# 1. Install APM CLI (if not already installed)
pip install apm-cli

# 2. Clone the repository
git clone https://github.com/fantasy-cc/agent-skill.git ~/agent-skills
cd ~/agent-skills

# 3. Install APM dependencies (skills + MCP servers)
apm install

# 4. Install skills-CLI packages (not managed by APM)
npx skills add vercel-labs/skills@find-skills -g -y
```

### Usage
To apply these skills globally across all your projects, link your global IDE directories to this repository's APM output:

```bash
# Link Google Antigravity
mkdir -p ~/.gemini/antigravity/skills
ln -snf ~/Project/agent_skill/.github/skills/project-init-iterate ~/.gemini/antigravity/skills/project-init-iterate

# Link Cursor
mkdir -p ~/.cursor/skills
ln -snf ~/Project/agent_skill/.github/skills/project-init-iterate ~/.cursor/skills/project-init-iterate

# Link Claude Code
mkdir -p ~/.claude/skills
ln -snf ~/Project/agent_skill/.claude/skills/project-init-iterate ~/.claude/skills/project-init-iterate
```

## Installed Packages

### Skills

| Skill | Manager | Description |
|-------|---------|-------------|
| [`project-init-iterate`](project-init-iterate/) | APM (local) | Generate and maintain project context documents (AGENTS.md, PLANS.md, FINDINGS.md, README.md) with auto-recovery hooks and context management rules |
| [`obra/superpowers`](https://github.com/obra/superpowers) | APM (GitHub) | Agentic dev methodology — brainstorming, TDD, code review, parallel agents, git worktrees (14 sub-skills) |
| [`find-skills`](https://github.com/vercel-labs/skills) | skills CLI | Discovers and installs skills from the open agent skills ecosystem |

### MCP Servers

| Server | Description |
|--------|-------------|
| `sequential-thinking` | Structured reasoning via MCP |
| `github-mcp` | GitHub API integration (issues, PRs, repos) |
| `playwright` | Browser automation via Anthropic's official Playwright server |

## Development

Want to add a new skill?

1. Create a new folder with a descriptive name (e.g., `api-scaffolder/`)
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`) and detailed instructions
3. Include any supporting files (templates, examples, scripts)
4. Add the skill to `apm.yml` dependencies under the `apm:` block
5. Run `apm install` to test that the compilation succeeds
6. Open a Pull Request

For skills from the vercel-labs ecosystem, install with:
```bash
npx skills add <owner>/<repo>@<skill-name> -g -y
```

## Project Structure

- `apm.yml` — Central manifest defining skills and MCP server dependencies
- `project-init-iterate/` — Custom skill for project context document generation
- `apm_modules/` — Downloaded APM dependencies (gitignored)
- `AGENTS.md` — AI agent context file for this repository
- `PLANS.md` — Living execution plan tracking ongoing work
- `FINDINGS.md` — Research log, discoveries, and error tracker
- `.claude/`, `.cursor/`, `.github/` — Compiled output for each IDE

## License

[MIT](LICENSE)
