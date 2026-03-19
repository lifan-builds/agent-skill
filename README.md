# agent-skill

A curated collection of AI agent skills — reusable instruction sets that give coding agents structured context and workflows for common tasks.

## Skills

| Skill | Description |
| ----- | ----------- |
| [`project-docs`](project-docs/) | Generate and maintain project context documents (`AGENTS.md`, `PLANS.md`, `README.md`) following OpenAI Agents SDK conventions |

## What Is a Skill?

A **skill** is a folder containing a `SKILL.md` file (with YAML frontmatter) and any supporting resources (templates, scripts, examples). AI coding agents read the `SKILL.md` to learn how to perform a specific task.

```
skill-name/
├── SKILL.md          # Main instructions (required)
├── templates.md      # Templates and examples (optional)
├── scripts/          # Helper scripts (optional)
└── examples/         # Reference implementations (optional)
```

## Installation

Copy individual skill folders into your agent's skills directory:

```bash
# Copy a single skill
cp -r project-docs/ ~/.cursor/skills/project-docs/

# Or clone the whole repo and symlink
git clone https://github.com/fantasy-cc/agent-skill.git ~/agent-skills
ln -s ~/agent-skills/project-docs ~/.cursor/skills/project-docs
```

## Contributing

Want to add a new skill?

1. Create a new folder with a descriptive name (e.g., `api-scaffolder/`)
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`) and detailed instructions
3. Include any supporting files (templates, examples, scripts)
4. Add an entry to the Skills table above
5. Open a Pull Request

## License

[MIT](LICENSE)
