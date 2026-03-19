# project-docs

An AI agent skill that generates and maintains three core project context documents — `AGENTS.md`, `PLANS.md`, and `README.md` — following [OpenAI Agents SDK](https://openai.github.io/openai-agents-python/) conventions.

## Why?

AI coding agents work best when they have structured context about the project they're operating in. This skill automates the creation and upkeep of that context so agents (and new human contributors) can hit the ground running.

## What It Generates

| Document    | Audience           | Purpose                                          |
| ----------- | ------------------ | ------------------------------------------------ |
| `AGENTS.md` | AI coding agents   | Compact project guide optimized for agent context |
| `PLANS.md`  | Agents & humans    | Living execution plan (ExecPlan format)           |
| `README.md` | Human contributors | Standard project README for onboarding            |

## Quick Start

### Installation

Copy the skill folder into your agent's skills directory:

```bash
# For Cursor
cp -r . ~/.cursor/skills/project-docs/

# Or clone directly
git clone https://github.com/fantasy-cc/agent-skill.git ~/.cursor/skills/project-docs/
```

### Usage

Once installed, trigger the skill through your AI agent:

- **Init mode** — Tell the agent to *"initialize project docs"* or *"scaffold the project"*. The agent will gather context and generate all three files at the project root.
- **Update mode** — Tell the agent to *"update project docs"* or *"sync docs"*. The agent will read the existing documents, analyze recent changes, and update each file accordingly.

## File Overview

| File                             | Description                                          |
| -------------------------------- | ---------------------------------------------------- |
| [`SKILL.md`](SKILL.md)          | Main skill instructions — the agent reads this file  |
| [`templates.md`](templates.md)  | ExecPlan skeleton, filled example, and guidelines    |

## How It Works

```
User request
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
│ README.md            │
└──────────┬───────────┘
           ▼
   Confirm & summarize
```

## Contributing

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-change`)
3. Commit your changes (`git commit -m 'Add my change'`)
4. Push to the branch (`git push origin feature/my-change`)
5. Open a Pull Request

## License

[MIT](LICENSE)
