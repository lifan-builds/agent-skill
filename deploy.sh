#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_MCP="$CLAUDE_DIR/.mcp.json"
CURSOR_DIR="$HOME/.cursor"
GEMINI_DIR="$HOME/.gemini/antigravity"

# ---------- helpers ----------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m  +\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$1"; }

# ---------- 1. APM install ----------
info "Running apm install..."
(cd "$REPO_DIR" && apm install)

# ---------- 2. Sync MCP servers to global configs ----------
for TARGET_MCP in "$CLAUDE_MCP" "$GEMINI_DIR/mcp_config.json"; do
info "Syncing MCP servers to $TARGET_MCP..."

python3 - "$REPO_DIR/apm.yml" "$TARGET_MCP" << 'PYEOF'
import sys, json, os
try:
    import yaml
except ImportError:
    # Fall back to a minimal YAML parser for simple structures
    print("  ! PyYAML not found, installing...", file=sys.stderr)
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "pyyaml"])
    import yaml

apm_path, mcp_path = sys.argv[1], sys.argv[2]

# Read apm.yml
with open(apm_path) as f:
    apm = yaml.safe_load(f)

mcp_servers = apm.get("dependencies", {}).get("mcp", [])
if not mcp_servers:
    print("  No MCP servers found in apm.yml")
    sys.exit(0)

# Read existing .mcp.json or create empty
if os.path.exists(mcp_path):
    with open(mcp_path) as f:
        # Handle empty files by defaulting to {}
        try:
            mcp_config = json.load(f)
        except json.JSONDecodeError:
            mcp_config = {}
else:
    mcp_config = {}

if "mcpServers" not in mcp_config:
    mcp_config["mcpServers"] = {}

# Merge each server from apm.yml into .mcp.json
added, skipped = [], []
for server in mcp_servers:
    name = server["name"]
    entry = {"command": server["command"], "args": server["args"]}
    if "env" in server:
        entry["env"] = server["env"]
    if "disabled" in server:
        entry["disabled"] = server["disabled"]
        
    if name in mcp_config["mcpServers"]:
        # Update if config differs
        existing = mcp_config["mcpServers"][name]
        if existing.get("command") == entry.get("command") and \
           existing.get("args") == entry.get("args") and \
           existing.get("env") == entry.get("env") and \
           existing.get("disabled") == entry.get("disabled"):
            skipped.append(name)
            continue
    mcp_config["mcpServers"][name] = entry
    added.append(name)

# Write back
with open(mcp_path, "w") as f:
    json.dump(mcp_config, f, indent=2)
    f.write("\n")

for name in added:
    print(f"  + {name}")
for name in skipped:
    print(f"  = {name} (unchanged)")
PYEOF
done

# ---------- 3. Symlink skills globally ----------
info "Setting up global skill symlinks..."

# Claude Code skills
mkdir -p "$CLAUDE_DIR/skills"
for skill_dir in "$REPO_DIR/.claude/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    target="$CLAUDE_DIR/skills/$skill_name"
    if [ -L "$target" ] || [ ! -e "$target" ]; then
        ln -snf "$skill_dir" "$target"
        ok "$skill_name -> Claude Code"
    else
        warn "$target exists and is not a symlink, skipping"
    fi
done

# Cursor skills
mkdir -p "$CURSOR_DIR/skills"
for skill_dir in "$REPO_DIR/.github/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    target="$CURSOR_DIR/skills/$skill_name"
    if [ -L "$target" ] || [ ! -e "$target" ]; then
        ln -snf "$skill_dir" "$target"
        ok "$skill_name -> Cursor"
    else
        warn "$target exists and is not a symlink, skipping"
    fi
done

# Gemini/Antigravity skills — global skills live at ~/.gemini/antigravity/skills/
GEMINI_GLOBAL_SKILLS="$GEMINI_DIR/skills"
mkdir -p "$GEMINI_GLOBAL_SKILLS"
for skill_dir in "$REPO_DIR/.github/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    target="$GEMINI_GLOBAL_SKILLS/$skill_name"
    if [ -L "$target" ] || [ ! -e "$target" ]; then
        ln -snf "$skill_dir" "$target"
        ok "$skill_name -> Antigravity (global)"
    else
        warn "$target exists and is not a symlink, skipping"
    fi
done

# ---------- 4. Install skills-CLI packages ----------
info "Installing skills-CLI packages..."
if command -v npx &>/dev/null; then
    # Check if find-skills is already installed
    if [ -d "$HOME/.agents/skills/find-skills" ]; then
        ok "find-skills (already installed)"
    else
        npx skills add vercel-labs/skills@find-skills -g -y
        ok "find-skills installed"
    fi
else
    warn "npx not found, skipping skills-CLI packages"
fi

# ---------- Cleanup ----------
# Focus only on Cursor, Antigravity, and Claude by removing VS Code artifacts if generated
rm -rf "$REPO_DIR/.vscode" 2>/dev/null || true

# ---------- Done ----------
echo ""
info "Deployment complete!"
echo "  Skills symlinked to: Claude Code, Cursor, Antigravity (~/.gemini/antigravity/skills/)"
echo "  MCP servers synced to: $CLAUDE_MCP, $GEMINI_DIR/mcp_config.json"
echo ""
echo "  Restart your AI IDEs to pick up the new skills and MCP servers."
