# Agent Guide

## Project Overview
`agent_skill` is a centralized configuration repository that acts as a global hub for AI tools, skills, and MCP servers. It uses Microsoft's Agent Package Manager (APM) and the vercel-labs skills CLI to resolve dependencies and compile instructions so that Cursor, Claude Code, and Google Antigravity can share identical configurations across the developer's entire machine.

## Tech Stack
- **APM (Agent Package Manager)** via `apm-cli` — primary package manager
- **skills CLI** (`npx skills`) — secondary, for vercel-labs ecosystem skills
- **Markdown** for skill definitions (`SKILL.md`)
- **YAML** for manifests (`apm.yml`)

## Project Structure
- `apm.yml`: The core manifest detailing skills (APM + GitHub), MCP servers, and local paths.
- `project-init-iterate/`: Custom skill for generating/updating project context docs (AGENTS.md, PLANS.md, FINDINGS.md, README.md) with auto-recovery hooks.
- `apm_modules/`: Downloaded APM dependencies (obra/superpowers, etc.). Gitignored.
- `.claude/skills/`, `.github/skills/`: Auto-generated compiled output folders created by APM.
- `~/.agents/skills/find-skills`: Globally installed via skills CLI, symlinked into Claude Code.
- Symlinks (e.g., `.cursor/skills`, `.agent/skills`): Maps APM output dynamically to their respective IDE configurations.

## Installed Skills & MCP Servers

| Name | Type | Manager | Description |
|------|------|---------|-------------|
| `project-init-iterate` | Skill (local) | APM | Project docs generation with FINDINGS.md and context management hooks |
| `obra/superpowers` | Skill (GitHub) | APM | Agentic dev methodology — brainstorming, TDD, code review, worktrees (14 sub-skills) |
| `find-skills` | Skill (global) | skills CLI | Discovers and installs skills from the open agent skills ecosystem |
| `sequential-thinking` | MCP | APM | Structured reasoning server |
| `github-mcp` | MCP | APM | GitHub API integration |
| `playwright` | MCP | APM | Browser automation via Playwright |

## Development Workflow
- To add an APM skill or MCP server: Modify `apm.yml`, then run `apm install`.
- To add a skills-CLI skill: Run `npx skills add <repo>@<skill> -g -y`.
- To use the skills globally: Symlink `~/.cursor/skills`, `~/.claude/skills`, and `~/.gemini/antigravity/skills` to the locally generated folders inside this repository.

## Coding Conventions
- New custom skills must be placed in their own subdirectories containing a `SKILL.md` file with YAML frontmatter (`name`, `description`).
- `apm.yml` uses the APM v0.1 schema format (lists under `apm:` or `mcp:` keys, not maps).
- Non-APM-compliant packages (raw MCP repos) go under `mcp:`, not `apm:`.

## Architecture Decisions
- **Migration to APM**: We discontinued the manual `install.sh` shell script because APM elegantly handles resolving remote dependencies and formatting outputs for VS Code/Claude.
- **Global Proxy**: Because APM outputs to the local project, we treat this repository as the single point-of-truth and physically symlink IDE global folders into it.
- **Dual Package Manager**: APM for skills with `apm.yml`/`SKILL.md` structure; skills CLI for the vercel-labs ecosystem (e.g., find-skills). Both coexist without conflict.
- **Puppeteer → Playwright**: Replaced puppeteer MCP with Anthropic's official playwright MCP server for browser automation.
- **FINDINGS.md separation**: External/untrusted content is logged to FINDINGS.md (not PLANS.md) to prevent prompt injection via auto-read hooks.
