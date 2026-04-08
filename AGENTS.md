# Agent Guide

## Project Overview
`agent-nexus` is a centralized configuration repository that acts as a global hub for AI tools, skills, and MCP servers. It uses Microsoft's Agent Package Manager (APM) and the vercel-labs skills CLI to resolve dependencies and compile instructions so that Cursor, Claude Code, and Google Antigravity can share identical configurations across the developer's entire machine.

## Tech Stack
- **APM (Agent Package Manager)** via `apm-cli` — primary package manager
- **skills CLI** (`npx skills`) — secondary, for vercel-labs ecosystem skills
- **Markdown** for skill definitions (`SKILL.md`)
- **YAML** for manifests (`apm.yml`)

## Project Structure
- `apm.yml`: The core manifest detailing skills (APM + GitHub), MCP servers (`mcp:` for core, `optional_mcp:` for opt-in), and local paths.
- `deploy.sh`: Runs `apm install`, prompts for optional MCPs, merges MCP entries from `apm.yml` into global configs (including `~/.claude.json`, `~/.cursor/mcp.json`, `~/.gemini/antigravity/mcp_config.json`), detects unmanaged entries in targets and offers to remove them, removes the repo-local `.cursor/mcp.json` after APM to avoid duplicate MCP registrations in Cursor, ensures the optional Xiaohongshu HTTP MCP entry is present when the Go binary is installed, and symlinks skills. Supports `--all` flag to auto-include optional MCPs and skip conflict prompts.
- `bin/`: Pre-built Go binaries — `xiaohongshu-mcp` (MCP server) and `xiaohongshu-login` (one-time auth) from xpzouying/xiaohongshu-mcp.
- `scripts/xhs-start`: Starts the xiaohongshu-mcp Go server in the background (HTTP on localhost:18060).
- `scripts/xhs-relogin`: Re-runs the login flow when the XHS session expires.
- `context-harness/`: Custom skill for generating/updating project context docs (AGENTS.md, PLANS.md, FINDINGS.md, EVALUATION.md, README.md) with auto-recovery hooks.
- `apm_modules/`: Downloaded APM dependencies (obra/superpowers, etc.). Gitignored.
- `.claude/skills/`, `.github/skills/`: Auto-generated compiled output folders created by APM.
- `~/.agents/skills/find-skills`: Globally installed via skills CLI, symlinked into Claude Code.
- Symlinks (e.g., `.cursor/skills`, `.agent/skills`): Maps APM output dynamically to their respective IDE configurations.

## Installed Skills & MCP Servers

| Name | Type | Manager | Description |
|------|------|---------|-------------|
| `context-harness` | Skill (local) | APM | Project docs generation with FINDINGS.md and context management hooks |
| `obra/superpowers` | Skill (GitHub) | APM | Agentic dev methodology — brainstorming, TDD, code review, worktrees (14 sub-skills) |
| `find-skills` | Skill (global) | skills CLI | Discovers and installs skills from the open agent skills ecosystem |
| `sequential-thinking` | MCP | APM | Structured reasoning server |
| `playwright` | MCP | APM | Browser automation via Playwright |
| `context7` | MCP | APM | Up-to-date library documentation retrieval |
| `nitan-mcp` | MCP | APM | Community MCP (`@nitansde/mcp`) |
| `github-mcp` (optional) | MCP | APM (`optional_mcp`) | GitHub API integration. Included via `--all` or interactive prompt. |
| `notion-mcp` (optional) | MCP | APM (`optional_mcp`) | Official Notion API integration. Included via `--all` or interactive prompt. |
| `xiaohongshu-mcp` (optional) | MCP | Manual / Go binary | **Not** declared in `apm.yml`. Uses [xpzouying/xiaohongshu-mcp](https://github.com/xpzouying/xiaohongshu-mcp) Go binary in `bin/`. Server runs locally on `http://localhost:18060/mcp`. Run `scripts/xhs-relogin` once to authenticate, then `scripts/xhs-start` to start. `deploy.sh` ensures the HTTP MCP entry exists in Claude Code and Cursor. |

## Development Workflow
- To add a core APM skill or MCP server: Add to `apm.yml` under `mcp:`, then run `apm install` and `./deploy.sh`.
- To add an optional MCP server: Add to `apm.yml` under `optional_mcp:`. It will be offered interactively during `./deploy.sh` or auto-included with `./deploy.sh --all`.
- To add a skills-CLI skill: Run `npx skills add <repo>@<skill> -g -y`.
- To deploy everything non-interactively: Run `./deploy.sh --all` (includes optional MCPs, keeps unmanaged entries).
- To use the skills globally: Symlink `~/.cursor/skills`, `~/.claude/skills`, and `~/.gemini/antigravity/skills` to the locally generated folders inside this repository (or rely on `deploy.sh` symlinks where applicable).

## Coding Conventions
- New custom skills must be placed in their own subdirectories containing a `SKILL.md` file with YAML frontmatter (`name`, `description`).
- `apm.yml` uses the APM v0.1 schema format (lists under `apm:` or `mcp:` keys, not maps). The custom `optional_mcp:` key is ignored by APM and handled by `deploy.sh`.
- Non-APM-compliant packages (raw MCP repos) go under `mcp:`, not `apm:`.

## Architecture Decisions
- **Migration to APM**: We discontinued the manual `install.sh` shell script because APM elegantly handles resolving remote dependencies and formatting outputs for VS Code/Claude.
- **Global Proxy**: Because APM outputs to the local project, we treat this repository as the single point-of-truth and physically symlink IDE global folders into it.
- **Dual Package Manager**: APM for skills with `apm.yml`/`SKILL.md` structure; skills CLI for the vercel-labs ecosystem (e.g., find-skills). Both coexist without conflict.
- **Puppeteer → Playwright**: Replaced puppeteer MCP with Microsoft's official playwright MCP server for browser automation.
- **FINDINGS.md separation**: External/untrusted content is logged to FINDINGS.md (not PLANS.md) to prevent prompt injection via auto-read hooks.
- **Claude/Cursor MCP + APM**: `deploy.sh` merges `apm.yml` MCP entries into `~/.claude.json` and `~/.cursor/mcp.json`, then deletes the workspace `.cursor/mcp.json` after `apm install` to prevent duplicate server entries when this repo is open in Cursor.
- **Optional MCPs**: `github-mcp` and `notion-mcp` are declared under `optional_mcp:` in `apm.yml` rather than `mcp:`. This key is not an APM standard — APM ignores it. `deploy.sh` reads it and either prompts interactively or auto-includes with `--all`.
- **Conflict Detection**: `deploy.sh` now compares managed MCPs (core + accepted optional + xiaohongshu) against entries in each target config. Unmanaged entries are flagged with options to keep, remove all, or decide interactively. Same logic applies to skill symlinks.
- **Xiaohongshu MCP**: Headless Playwright-based packages (Node/Python) proved flaky against the live site. The Chrome extension approach (x-mcp) hit page load timeouts on the hosted endpoint. The current approach is the **xpzouying/xiaohongshu-mcp** Go binary — 12.5k+ stars, HTTP transport on localhost:18060, no Playwright dependency. Binary lives in `bin/`; use `scripts/xhs-relogin` + `scripts/xhs-start`.
