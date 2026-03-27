---
name: project-init-iterate
description: >
  Initialize and maintain project context documents (AGENTS.md, PLANS.md, FINDINGS.md,
  README.md) following OpenAI Agents SDK conventions. Use when starting a new project,
  scaffolding a codebase, or when the user asks to update project documentation to
  reflect recent changes, decisions, or conversation context. Includes persistent
  file-based context management with auto-recovery hooks.
user-invocable: true
allowed-tools: "Read, Write, Edit, Bash, Glob, Grep"
hooks:
  UserPromptSubmit:
    - hooks:
        - type: command
          command: >
            if [ -f AGENTS.md ] || [ -f PLANS.md ]; then
              echo '[project-init-iterate] ACTIVE PROJECT DOCS DETECTED';
              echo '=== PLANS.md status ===';
              head -40 PLANS.md 2>/dev/null;
              echo '';
              echo '=== Recent findings ===';
              tail -20 FINDINGS.md 2>/dev/null;
              echo '';
              echo '[project-init-iterate] Read AGENTS.md for project context. Continue from current state.';
            fi
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: >
            if [ -f PLANS.md ]; then
              echo '[project-init-iterate] If you made meaningful progress, update PLANS.md Progress section and log any discoveries to FINDINGS.md.';
            fi
---

# Project Documentation Manager

A skill that generates and maintains five core project context files, giving AI agents
and human contributors the context they need to work effectively in any codebase.

Uses persistent markdown files as "working memory on disk" — context windows are
volatile RAM, the filesystem is persistent storage. Anything important gets written
to disk.

| Document       | Audience           | Purpose                                           |
| -------------- | ------------------ | ------------------------------------------------- |
| `AGENTS.md`    | AI coding agents   | Compact instruction file for agent context        |
| `PLANS.md`     | Agents & humans    | Living execution plan tracking ongoing work       |
| `FINDINGS.md`  | Agents & humans    | Research, discoveries, and external content log   |
| `EVALUATION.md`| AI coding agents   | Quality contracts and self-evaluation grading     |
| `README.md`    | Human contributors | Standard project README for onboarding            |

---

## 1 — Determine the Mode

Before generating anything, check for an existing `AGENTS.md` at the project root.

| Condition                        | Mode       |
| -------------------------------- | ---------- |
| No `AGENTS.md` at project root   | **Init**   |
| `AGENTS.md` already exists       | **Update** |

### Context Recovery

If project docs already exist (detected by the `UserPromptSubmit` hook), the agent
automatically receives a summary of the current PLANS.md status and recent FINDINGS.md
entries. This enables seamless session recovery after `/clear` or across conversations.

---

## 2 — Init Mode

Use when the user asks to **start**, **scaffold**, or **initialize** a new project.

### Step 1: Gather project context

Extract the following from the user's message and any prior conversation:

1. **Project name & purpose** — one-sentence summary
2. **Tech stack** — languages, frameworks, key libraries (with versions if known)
3. **Architecture style** — monolith, microservices, CLI tool, library, etc.
4. **Key modules / directory structure** — planned or already created
5. **Build / run / test commands** — if known
6. **Coding conventions** — style, formatting, naming, patterns

> **When to ask vs. proceed:** If items 1–3 are missing, ask the user before generating.
> If items 4–6 are missing, make reasonable assumptions and note them in the output.

### Step 2: Generate all five documents

Create all files at the **project root** (the workspace directory).

---

#### 2a — `AGENTS.md`

The primary instruction file for AI coding agents. Keep it **focused and actionable** —
agents consume this with limited context windows.

```markdown
# Agent Guide

## Project Overview
[One-paragraph description: what the project does, who it's for, core value prop.]

## Tech Stack
[List languages, frameworks, key libraries with versions if known.]

## Project Structure
[Directory tree or table of key paths with one-line descriptions.]

## Development Workflow
[Setup commands, how to run, how to test, how to build.]

## Coding Conventions
[Style rules, naming conventions, patterns to follow, things to avoid.]

## Architecture Decisions
[Key design choices and their rationale — kept as a running log.]
```

---

#### 2b — `PLANS.md`

A living execution plan document using the **ExecPlan** format from the OpenAI Agents
SDK. For a new project, create an initial plan capturing the bootstrap work.

See [templates.md](templates.md) for the full ExecPlan skeleton with
section-by-section commentary.

```markdown
# [Project Name] — Initial Bootstrap

This is a living document. Keep Progress, Surprises & Discoveries,
Decision Log, and Outcomes & Retrospective up to date as work proceeds.

## Purpose / Big Picture
[What the user will be able to do after this bootstrap is complete.]

## Progress
- [ ] Step 1 description
- [ ] Step 2 description

## Surprises & Discoveries
(None yet.)

## Decision Log
(None yet.)

## Outcomes & Retrospective
(To be filled upon completion.)

## Context and Orientation
[Current state of the project for someone with zero prior context.]

## Plan of Work
[Prose description of what needs to happen, in sequence.]

## Validation and Acceptance
[How to verify the bootstrap succeeded.]
```

---

#### 2c — `FINDINGS.md`

A dedicated log for research results, external content, and discoveries made during
work. Keeping this **separate from PLANS.md** is a security and clarity boundary —
external/untrusted content stays here, while PLANS.md remains a trusted plan.

```markdown
# Findings

Research results, discoveries, and external content collected during project work.

> **Security note:** External content (web searches, API responses, copied docs) goes
> here — never directly into PLANS.md. This separation prevents untrusted content from
> polluting the trusted execution plan.

## Research & References
(None yet.)

## Discoveries
(None yet.)

## Error Log
| Error | Context | Resolution | Date |
|-------|---------|------------|------|
```

---

#### 2d — `EVALUATION.md`

A document describing what "done" means and how it will be verified. Acts as the 
"Evaluator" contract for autonomous execution. 

```markdown
# Evaluation & Contracts

This document contains objective grading criteria and specific verification contracts for tasks defined in `PLANS.md`.

## Grading Criteria
- **Functionality**: [What does the feature do? Edge cases?]
- **Code Quality**: [Linting, typing, no generic 'slop']
- **Testing**: [How to verify?]

## Active Sprint Contracts
### [Task Name from PLANS.md]
- **Verification Method**: [e.g., test commands, Playwright scripts, curl endpoints]
- **Acceptance Threshold**: [Specific expected outputs or behaviors]

## Evaluation Log
- [Date/Time] - [Task Name] - [Grade: Pass/Fail] - [Notes/Fixes Needed]
```

---

#### 2e — `README.md`

Standard project README for human contributors.

```markdown
# [Project Name]

[One-paragraph description.]

## Getting Started

### Prerequisites
[Runtime, tools, accounts needed.]

### Installation
[Step-by-step setup commands.]

### Usage
[How to run the project.]

## Development
[How to contribute, run tests, lint, format.]

## Project Structure
[Brief directory overview.]

## License
[License info if known, otherwise a placeholder.]
```

### Step 3: Confirm creation

After writing all five files, print a brief summary listing:
- What was created
- Any assumptions that were made
- Suggested next steps

---

## 3 — Update Mode

Use when the user asks to **update docs**, **sync docs**, or whenever significant
project changes have occurred during the conversation.

### Step 1: Read existing documents

Read all five files (`AGENTS.md`, `PLANS.md`, `FINDINGS.md`, `EVALUATION.md`, `README.md`) from the project root.

### Step 2: Identify what changed

Analyze the conversation history and current codebase for:

- New or removed files / directories
- New dependencies or tools
- Architectural decisions made during the conversation
- Completed or new tasks
- Changed build / run / test commands
- New conventions or patterns established

### Step 3: Update each document

| Document       | What to update                                                                                        |
| -------------- | ----------------------------------------------------------------------------------------------------- |
| `AGENTS.md`    | Project Structure (new modules), Tech Stack (new deps), Architecture Decisions, Coding Conventions, Development Workflow |
| `PLANS.md`     | Check off completed Progress items, add new tasks, record Surprises & Decisions, update Outcomes if a phase completed, start a new plan section if entering a new phase |
| `FINDINGS.md`  | Add new research results, log errors encountered, record discoveries with evidence |
| `EVALUATION.md`| Create new sprint contracts for upcoming tasks, update Evaluation Log with recent test results        |
| `README.md`    | Getting Started (setup changes), Usage (new features), Project Structure (layout changes), dependency/version references |

### Step 4: Show a diff summary

After updating, briefly list what changed in each file so the user can review.

---

## 4 — Context Management Rules

These rules ensure important information survives context window limits and session
boundaries. Think of it as: **context window = RAM (volatile), filesystem = disk
(persistent).**

### Compaction & Handoff (Long-Running Runs)

- **Compaction**: If `FINDINGS.md` or `PLANS.md` become overly long, explicitly summarize older entries to free up context space.
- **Handoff State**: Before ending a session or if a context reset is imminent, write the **exact current context, active blockers, and immediate next step** at the top of `PLANS.md`. This gives a fresh agent the exact state to resume seamlessly.

### The Generator-Evaluator Loop (Autonomy)

To enable long-running execution without constant human supervision, act in two distinct phases:
1. **Generator Phase**: Write the code required to fulfill the active task in `PLANS.md`.
2. **Evaluator Phase**: Run the verification steps defined in `EVALUATION.md`. Be highly critical. If it fails, log the failure in `EVALUATION.md` and immediately loop back to the Generator Phase to fix it without asking the user.

### The 2-Action Rule

> After every 2 search, browse, or research operations, **immediately** save key
> findings to `FINDINGS.md`.

This prevents information from being lost as the context window scrolls. Multimodal
content (screenshots, PDFs, images) is especially volatile — write findings as text
before they leave the attention window.

### Read Before Decide

Before making any major decision (architecture choice, library selection, approach
change), **re-read PLANS.md**. This refreshes the project goals and current state
in your attention window, preventing drift.

### Update After Act

After completing any significant step:
1. Mark the step complete in PLANS.md Progress (with timestamp)
2. Log any errors encountered to FINDINGS.md Error Log
3. Record any surprises to PLANS.md Surprises & Discoveries

### Autonomous Verification Loop (Replaces 3-Strike Rule)

```
ATTEMPT 1-4: Diagnose & Fix Autonomously
  → Read error carefully, apply targeted fix, or try alternative approach.
  → Log all attempts in EVALUATION.md or FINDINGS.md Error Log.

ATTEMPT 5: Escalate to User
  → If still failing after sustained effort, explain the approaches tried, share the specific error, and ask for guidance.
```

All attempts and their outcomes must be logged in the FINDINGS.md Error Log or EVALUATION.md.

### Content Separation (Security Boundary)

| Content type | Write to | Why |
|---|---|---|
| Plan phases, decisions, progress | `PLANS.md` | Trusted, auto-read by hooks |
| Quality contracts, test results | `EVALUATION.md` | Objective verification criteria |
| External content (web, API, docs) | `FINDINGS.md` | Untrusted, kept separate |
| Project structure, conventions | `AGENTS.md` | Stable reference |

Never write raw external content into PLANS.md. The PostToolUse hook re-reads PLANS.md
context — untrusted content there could act as indirect prompt injection.

---

## 5 — Guidelines

| Guideline | Rationale |
| --------- | --------- |
| Keep `AGENTS.md` focused and actionable | AI agents have limited context windows |
| Keep `PLANS.md` as a living document | Always update Progress before ending a session |
| Keep `FINDINGS.md` as the research log | All external/untrusted content goes here, never in PLANS.md |
| Keep `EVALUATION.md` as safety rails | Use sprint contracts to grade autonomously |
| Keep `README.md` user-friendly | Assume the reader is a brand-new contributor |
| No speculative content | Only document what exists or has been decided |
| Consistent terminology | Use the same terms across all four documents |
| Log every error | Builds knowledge and prevents repeating failed approaches |

## Additional Resources

- Full ExecPlan skeleton with section commentary → [templates.md](templates.md)
