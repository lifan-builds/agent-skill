# personal-agent-setup-manager — Initial Bootstrap

This is a living document. Keep Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective up to date as work proceeds.

## Handoff (session state)

- **Last updated:** 2026-04-03
- **Focus:** Xiaohongshu MCP switched from broken x-mcp (hosted endpoint) to **xpzouying/xiaohongshu-mcp** Go binary (localhost:18060).
- **Done:** Go binaries in `bin/`; `scripts/xhs-start` + `scripts/xhs-relogin` added; legacy Node/Python XHS tooling removed; `~/.cursor/mcp.json` updated to localhost URL; `deploy.sh` simplified; Claude Code login and `search_feeds` verified successfully.
- **Open:** Keep `deploy.sh` aligned with Claude Code's real MCP config path (`~/.claude.json`) and keep generated session state out of git.

## Purpose / Big Picture
Establish a single, APM-powered repository that centrally manages agent skills and MCP servers globally for all local IDEs (Cursor, Claude Code, Antigravity).

## Progress
- [x] Initial legacy `install.sh` removal
- [x] APM Initialization and `apm.yml` configuration
- [x] First `apm install` and lockfile generation
- [x] Creation of symlink commands for global IDE hookups
- [x] Run `context-harness` to bootstrap `AGENTS.md`, `PLANS.md`, and `README.md`
- [x] (2026-03-22) Enhanced `context-harness` with FINDINGS.md, auto-recovery hooks, and context management rules (2-Action Rule, Read Before Decide, 3-Strike Error Protocol)
- [x] (2026-03-22) Replaced puppeteer MCP with Anthropic's official playwright MCP server
- [x] (2026-03-22) Installed `obra/superpowers` via APM (14 sub-skills, 6 hooks)
- [x] (2026-03-26) Renamed local skill to `context-harness` and generated `EVALUATION.md`.
- [x] (2026-03-26) Extracted `context-harness` into its own standalone GitHub repository (`fantasy-cc/context-harness`) and updated `apm.yml` to pull from remote.
- [x] (2026-04-03) Cursor: merge `apm.yml` MCP list into `~/.cursor/mcp.json`; remove generated workspace `.cursor/mcp.json` on deploy to stop duplicate MCP entries.
- [x] (2026-04-03) Xiaohongshu: adopt **x-mcp** (browser extension + hosted HTTP MCP); remove `xiaohongshu-mcp` from `apm.yml`.
- [x] (2026-04-03) Xiaohongshu: replace broken x-mcp with **xpzouying/xiaohongshu-mcp** Go binary; remove all legacy Node/Python XHS tooling; update configs.
- [x] (2026-04-04) Complete first login via `scripts/xhs-relogin` and verify `check_login_status` plus `search_feeds` from Claude Code.

## Surprises & Discoveries
- APM does not inherently contain an `antigravity` compilation target, so we opted to route Google Antigravity to the `.github/skills` compilation using symlinks, which effectively acts as a universal agent output.
- Non-APM-compliant repositories (like raw MCP github repositories) must be configured under the `mcp:` array in `apm.yml` rather than the `apm:` array to prevent parser failure.
- `chrisboden/find-skills` is NOT a valid APM package (just a README catalog). The canonical `find-skills` lives in `vercel-labs/skills` and installs via `npx skills add`, not APM.
- APM and the skills CLI coexist without conflict — APM deploys to `.claude/skills/`, skills CLI deploys to `~/.agents/skills/` and symlinks into `~/.claude/skills/`.
- Hooks defined in SKILL.md YAML frontmatter are auto-executed by Claude Code — no separate settings.json configuration needed.
- Xiaohongshu automation via headless Playwright (Node/Python MCP packages) hit recurring issues: certificate/load semantics, fragile login selectors, and signing/session drift; extension-backed MCP is the practical default.
- x-mcp (Chrome extension + `mcp.aredink.com` hosted endpoint) failed with persistent page load timeouts; replaced with the locally-run Go binary (xpzouying/xiaohongshu-mcp, 12.5k+ stars) serving MCP over HTTP at localhost:18060.

## Decision Log
- **Adopted APM over Bash Scripts**: Removed `install.sh` to leverage Microsoft APM for declarative dependency management.
- **Adopted Symlink Strategy**: Recommended symlinking `~/.cursor/skills` and equivalent folders to this repository to create a true, zero-config global setup.
- **Dual Package Manager**: APM for structured skills; skills CLI for vercel-labs ecosystem. Both deploy to different paths and don't conflict.
- **Puppeteer → Playwright**: Switched to `@anthropic-ai/mcp-server-playwright` (Anthropic's official server) for better maintenance and capability.
- **FINDINGS.md as security boundary**: External content separated from PLANS.md to prevent prompt injection via auto-read hooks.
- **Xiaohongshu via Go binary**: Replaced x-mcp (flaky hosted endpoint) with xpzouying/xiaohongshu-mcp Go binary. Binary in `bin/`, HTTP MCP at localhost:18060. `deploy.sh` ensures the optional HTTP entry exists in `~/.claude.json` and `~/.cursor/mcp.json`.

## Outcomes & Retrospective
The core transition to an APM-based architecture has successfully replaced handwritten copying scripts. The toolkit includes 3 skills (context-harness, superpowers, find-skills) and multiple MCP servers declared in `apm.yml` (including playwright, context7, nitan-mcp, notion-mcp), with auto-recovery hooks for session continuity. Deployment now targets **Claude Code** and **Cursor** MCP config globally. Xiaohongshu is handled outside the manifest via the local Go HTTP server, with helper scripts and deploy-time MCP registration kept in-repo. The `context-harness` skill supports explicit evaluation contracts (`EVALUATION.md`) and is consumed from GitHub via APM.

## Context and Orientation
The repository consists of `apm.yml` for dependencies, `deploy.sh` for global sync (skills + MCP JSON for Claude, Cursor, Antigravity), local subdirectories (e.g. `context-harness/`) for custom skills, `scripts/` for optional Xiaohongshu troubleshooting, and `apm_modules/` for downloaded dependencies. Skills are also installed globally via the skills CLI (`~/.agents/skills/`). The context-harness skill maintains five documents (AGENTS.md, PLANS.md, FINDINGS.md, EVALUATION.md, README.md) with context management rules.

## Plan of Work
- Future tasks involve adding SSH auth functionality so private `git@` repos can be downloaded.
- Integrate more generic workflows into their own subdirectories with `SKILL.md`.
- Evaluate additional domain-specific skills (frontend-design, web-design-guidelines) as needed.
- **Xiaohongshu:** Run `scripts/xhs-relogin` to complete initial auth, start server with `scripts/xhs-start`, then validate tools end-to-end from Cursor.

## Validation and Acceptance
- Verified that `apm install` writes the dependencies efficiently.
- Verified IDE integrations recognize the compiled Markdown outputs.
- Verified `obra/superpowers` hooks integrated into Claude Code, Cursor, and GitHub.
- Verified `find-skills` symlinked into `~/.claude/skills/` and recognized by Claude Code.
- **Cursor MCP:** `deploy.sh` updates `~/.cursor/mcp.json` from `apm.yml` without removing manually added servers (merge-by-name).
- **Xiaohongshu (Go binary):** Verified in Claude Code: `check_login_status` succeeds and `search_feeds` returns live results.
