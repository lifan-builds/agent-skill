# project-init-iterate

Generate and maintain four core project context documents — `AGENTS.md`, `PLANS.md`, `FINDINGS.md`, and `README.md` — with persistent file-based context management and auto-recovery hooks.

## What It Generates

| Document       | Audience           | Purpose                                            |
| -------------- | ------------------ | -------------------------------------------------- |
| `AGENTS.md`    | AI coding agents   | Compact project guide optimized for agent context  |
| `PLANS.md`     | Agents & humans    | Living execution plan (ExecPlan format)            |
| `FINDINGS.md`  | Agents & humans    | Research log, discoveries, and error tracker       |
| `README.md`    | Human contributors | Standard project README for onboarding             |

## Key Features

- **Auto-recovery hooks** — `UserPromptSubmit` hook detects existing project docs and restores context after `/clear` or across sessions
- **Progress reminders** — `PostToolUse` hook reminds the agent to update PLANS.md and FINDINGS.md after writes
- **Content separation** — External/untrusted content goes to FINDINGS.md, keeping PLANS.md clean and safe from prompt injection
- **Context management rules** — 2-Action Rule, Read Before Decide, 3-Strike Error Protocol
- **Init & Update modes** — Bootstrap new projects or sync docs with codebase changes

## Usage

Once installed, trigger the skill through your AI agent:

- **Init mode** — *"Initialize project docs"* — generates all four files from scratch
- **Update mode** — *"Update project docs"* — reads existing docs, analyzes recent changes, and updates

## Files

| File                             | Description                                          |
| -------------------------------- | ---------------------------------------------------- |
| [`SKILL.md`](SKILL.md)          | Main skill instructions (read by the agent)          |
| [`templates.md`](templates.md)  | ExecPlan skeleton, FINDINGS template, and guidelines |

## How It Works

```
User request (or session recovery via hook)
    │
    ▼
┌─────────────────┐
│ AGENTS.md exist? │
└────┬────────┬────┘
     │ No     │ Yes
     ▼        ▼
  Init      Update
  Mode       Mode
     │        │
     ▼        ▼
┌──────────────────────┐
│ Gather project info  │
│ from user + codebase │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│ Generate / update    │
│ AGENTS.md            │
│ PLANS.md             │
│ FINDINGS.md          │
│ README.md            │
└──────────┬───────────┘
           ▼
   Confirm & summarize
```

## Context Management

The skill includes rules adapted from the [Manus-style planning methodology](https://github.com/OthmanAdi/planning-with-files):

| Rule | Description |
|------|-------------|
| **2-Action Rule** | Save findings to FINDINGS.md every 2 research operations |
| **Read Before Decide** | Re-read PLANS.md before major decisions to prevent drift |
| **Update After Act** | Mark progress, log errors, record surprises after each step |
| **3-Strike Error Protocol** | Diagnose → Alternative → Rethink → Escalate to user |
| **Content Separation** | External content in FINDINGS.md only, never in PLANS.md |
