# agent_skill — Initial Bootstrap

This is a living document. Keep Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective up to date as work proceeds.

## Purpose / Big Picture
Establish a single, APM-powered repository that centrally manages agent skills and MCP servers globally for all local IDEs (Cursor, Claude Code, Antigravity).

## Progress
- [x] Initial legacy `install.sh` removal
- [x] APM Initialization and `apm.yml` configuration
- [x] First `apm install` and lockfile generation
- [x] Creation of symlink commands for global IDE hookups
- [x] Run `project-init-iterate` to bootstrap `AGENTS.md`, `PLANS.md`, and `README.md`
- [x] (2026-03-22) Enhanced `project-init-iterate` with FINDINGS.md, auto-recovery hooks, and context management rules (2-Action Rule, Read Before Decide, 3-Strike Error Protocol)
- [x] (2026-03-22) Replaced puppeteer MCP with Anthropic's official playwright MCP server
- [x] (2026-03-22) Installed `obra/superpowers` via APM (14 sub-skills, 6 hooks)
- [x] (2026-03-22) Installed `find-skills` via skills CLI (globally symlinked into Claude Code)
- [x] (2026-03-22) Created `FINDINGS.md` for research/discovery tracking

## Surprises & Discoveries
- APM does not inherently contain an `antigravity` compilation target, so we opted to route Google Antigravity to the `.github/skills` compilation using symlinks, which effectively acts as a universal agent output.
- Non-APM-compliant repositories (like raw MCP github repositories) must be configured under the `mcp:` array in `apm.yml` rather than the `apm:` array to prevent parser failure.
- `chrisboden/find-skills` is NOT a valid APM package (just a README catalog). The canonical `find-skills` lives in `vercel-labs/skills` and installs via `npx skills add`, not APM.
- APM and the skills CLI coexist without conflict — APM deploys to `.claude/skills/`, skills CLI deploys to `~/.agents/skills/` and symlinks into `~/.claude/skills/`.
- Hooks defined in SKILL.md YAML frontmatter are auto-executed by Claude Code — no separate settings.json configuration needed.

## Decision Log
- **Adopted APM over Bash Scripts**: Removed `install.sh` to leverage Microsoft APM for declarative dependency management.
- **Adopted Symlink Strategy**: Recommended symlinking `~/.cursor/skills` and equivalent folders to this repository to create a true, zero-config global setup.
- **Dual Package Manager**: APM for structured skills; skills CLI for vercel-labs ecosystem. Both deploy to different paths and don't conflict.
- **Puppeteer → Playwright**: Switched to `@anthropic-ai/mcp-server-playwright` (Anthropic's official server) for better maintenance and capability.
- **FINDINGS.md as security boundary**: External content separated from PLANS.md to prevent prompt injection via auto-read hooks.

## Outcomes & Retrospective
The core transition to an APM-based architecture has successfully replaced handwritten copying scripts. The toolkit now includes 3 skills (project-init-iterate, superpowers, find-skills) and 3 MCP servers (sequential-thinking, github-mcp, playwright), with auto-recovery hooks for session continuity.

## Context and Orientation
The repository consists of `apm.yml` for dependencies, local subdirectories (e.g. `project-init-iterate/`) for custom skills, and `apm_modules/` for downloaded dependencies. Skills are also installed globally via the skills CLI (`~/.agents/skills/`). The project-init-iterate skill now generates four documents (AGENTS.md, PLANS.md, FINDINGS.md, README.md) with context management rules borrowed from the Manus-style planning methodology.

## Plan of Work
- Future tasks involve adding SSH auth functionality so private `git@` repos can be downloaded.
- Integrate more generic workflows into their own subdirectories with `SKILL.md`.
- Evaluate additional domain-specific skills (frontend-design, web-design-guidelines) as needed.

## Validation and Acceptance
- Verified that `apm install` writes the dependencies efficiently.
- Verified IDE integrations recognize the compiled Markdown outputs.
- Verified `obra/superpowers` hooks integrated into Claude Code, Cursor, and GitHub.
- Verified `find-skills` symlinked into `~/.claude/skills/` and recognized by Claude Code.
