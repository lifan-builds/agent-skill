# Evaluation & Contracts

This document contains objective grading criteria and specific verification contracts for tasks defined in `PLANS.md`.

## Grading Criteria
- **Functionality**: Must seamlessly maintain context, update documents accurately, and support agent continuity over multiple sessions.
- **Code Quality**: APM paths, sync protocols, and standard conventions must stay intact. No generic or hallucinated paths.
- **Testing**: Can be verified by running `deploy.sh` and ensuring IDEs successfully recognize the installed skills without errors.

## Active Sprint Contracts
### [Extract Context-Harness to GitHub]
- **Verification Method**: `apm install` succeeds and correctly resolves `fantasy-cc/context-harness` from GitHub.
- **Acceptance Threshold**: The APM lockfile and `.github/skills/` reflect the new remote repository path.

### [Xiaohongshu MCP via Go binary]
- **Verification Method**: Run `scripts/xhs-relogin` to authenticate, start server with `scripts/xhs-start`, then invoke `check_login_status` and `search_feeds` from Claude Code or Cursor and observe success responses.
- **Acceptance Threshold**: At least one non-error tool response with the Go binary server running.

## Evaluation Log
- [2026-03-26] - [Extract Context-Harness to GitHub] - [Grade: Pass] - [Skill successfully extracted to separate Git repo, published, and linked via APM.]
- [2026-04-03] - [Xiaohongshu MCP via x-mcp (Cursor)] - [Grade: Fail] - [MCP appears in Cursor; `check_login_status` returned page load timeout — replaced with Go binary approach.]
- [2026-04-04] - [Xiaohongshu MCP via Go binary] - [Grade: Pass] - [Validated in Claude Code: `check_login_status` succeeded and `search_feeds` returned live results.]
