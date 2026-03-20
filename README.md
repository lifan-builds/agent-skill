# agent-skill

A curated collection of AI agent skills — reusable instruction sets that give coding agents structured context and workflows for common tasks.

## Skills

| Skill | Description |
| ----- | ----------- |
| [`project-init-iterate`](project-init-iterate/) | Generate and maintain project context documents (`AGENTS.md`, `PLANS.md`, `README.md`) following OpenAI Agents SDK conventions |

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

We provide an `install.sh` script to install skills into your project or globally for different IDEs. The script supports `cursor`, `claude`, and `antigravity`.

```bash
# 1. Clone the repository
git clone https://github.com/fantasy-cc/agent-skill.git ~/agent-skills
cd ~/agent-skills

# 2. Install a skill for a specific IDE (Local to your current project)
./install.sh <skill-name> <ide>

# Example: Install to the current project's .cursor/skills/ directory
./install.sh project-init-iterate cursor

# 3. Install globally to your home directory (e.g. ~/.cursor/skills/)
./install.sh project-init-iterate cursor --global
```

### Supported IDEs
- **cursor**: Installs to `.cursor/skills/` (local) or `~/.cursor/skills/` (global)
- **claude**: Installs to `.claude/skills/` (local) or `~/.claude/skills/` (global)
- **antigravity**: Installs to `.agent/skills/` (local) or `~/.gemini/antigravity/skills/` (global)

## Contributing

Want to add a new skill?

1. Create a new folder with a descriptive name (e.g., `api-scaffolder/`)
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`) and detailed instructions
3. Include any supporting files (templates, examples, scripts)
4. Add an entry to the Skills table above
5. Open a Pull Request

## License

[MIT](LICENSE)
