# Findings

Research results, discoveries, and external content collected during project work.

> **Security note:** External content (web searches, API responses, copied docs) goes
> here — never directly into PLANS.md. This keeps the trusted plan free of untrusted
> content.

## Research & References

### planning-with-files skill analysis
- **Source:** https://github.com/OthmanAdi/planning-with-files
- **Date:** 2026-03-22
- **Summary:** Community skill (v2.26.1) implementing Manus-style file-based planning with three files (task_plan.md, findings.md, progress.md). Key strengths borrowed into context-harness: auto-recovery hooks (UserPromptSubmit, PostToolUse), FINDINGS.md separation for security, 2-Action Rule, Read Before Decide, 3-Strike Error Protocol. Task-centric (per-task) vs our project-centric (long-lived) approach.

### find-skills ecosystem
- **Source:** https://github.com/vercel-labs/skills
- **Date:** 2026-03-22
- **Summary:** Canonical find-skills is at `vercel-labs/skills@find-skills`, installed via `npx skills add`. `chrisboden/find-skills` is NOT a valid package (just a README catalog). The skills CLI (`npx skills`) is a separate ecosystem from APM — deploys to `~/.agents/skills/` with symlinks into IDE skill dirs.

### Xiaohongshu MCP options — research history
- **Source:** Community repos, prior debugging, web search (2026-04-03).
- **Date:** 2026-04-03
- **Summary:** Headless Playwright MCPs (Node `@sillyl12324/xhs-mcp`, Python `xiaohongshu-mcp-server`) hit SSL strictness, partial page loads, and brittle login/signing. x-mcp Chrome extension + `mcp.aredink.com` hosted endpoint got page load timeouts. **Current approach:** [xpzouying/xiaohongshu-mcp](https://github.com/xpzouying/xiaohongshu-mcp) Go binary (~12.5k stars, March 2026 releases) — HTTP transport on `localhost:18060`, no Playwright dep. Binaries in `bin/`; `deploy.sh` now ensures the HTTP entry exists in both `~/.claude.json` and `~/.cursor/mcp.json`.

## Discoveries

- **Observation:** APM and skills CLI coexist without conflict
  **Evidence:** APM deploys to project `.claude/skills/`, skills CLI deploys to `~/.agents/skills/` with symlinks into `~/.claude/skills/`. No path collisions.
  **Impact:** Can use both package managers freely based on package availability.

- **Observation:** Hooks in SKILL.md YAML frontmatter are auto-executed by Claude Code
  **Evidence:** After deploying updated context-harness with hooks, the UserPromptSubmit hook fired successfully on next prompt (showed PLANS.md status and FINDINGS.md tail).
  **Impact:** No need for separate settings.json hook configuration for skill-defined hooks.

- **Observation:** APM resolves GitHub dependencies directly without needing a local path override, and fetches them on `apm install`.
  **Evidence:** Set `fantasy-cc/context-harness` in `apm.yml`, and `apm install` dynamically pulled it into `.github/skills`.
  **Impact:** Enables smooth extraction of custom generic skills to public Github packages while retaining them seamlessly in the central agent configuration.

- **Observation:** `deploy.sh` MCP merge preserves servers not listed in `apm.yml` (it only adds/updates names present in the manifest).
  **Evidence:** Merge script reads existing JSON and updates entries by name from YAML; no deletion pass.
  **Impact:** Manual `xiaohongshu-mcp` HTTP entries in `~/.cursor/mcp.json` survive deploy cycles.

- **Observation:** Claude Code user-scoped MCP servers live in `~/.claude.json`, not `~/.claude/.mcp.json`.
  **Evidence:** `claude mcp add --scope user ...` wrote `xiaohongshu-mcp` into `~/.claude.json`, and Claude Code only surfaced the server after that file was updated.
  **Impact:** Repo automation must target `~/.claude.json` for reproducible Claude MCP setup.

## Error Log
| Error | Context | Attempt | Resolution | Date |
|-------|---------|---------|------------|------|
| `chrisboden/find-skills` install failed | `apm install` — "Not a valid APM package" | 1: checked repo — no SKILL.md, just README | Removed from apm.yml; installed canonical version via `npx skills add vercel-labs/skills@find-skills -g -y` | 2026-03-22 |
| `check_login_status` / login flow: **Page load timeout** (Chinese message: 导航失败 / 工具执行错误) | x-mcp HTTP MCP from Cursor after configuring extension + API key | 1: treat as extension-side navigation timeout — verify extension connected, XHS open/logged in, retry | **Resolved by replacement** — switched to xpzouying/xiaohongshu-mcp Go binary | 2026-04-03 |
