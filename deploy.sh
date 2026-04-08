#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_MCP="$HOME/.claude.json"
CURSOR_DIR="$HOME/.cursor"
CURSOR_MCP="$CURSOR_DIR/mcp.json"
WORKSPACE_CURSOR_MCP="$REPO_DIR/.cursor/mcp.json"
GEMINI_DIR="$HOME/.gemini/antigravity"
XHS_BIN="$REPO_DIR/bin/xiaohongshu-mcp"
XHS_MCP_URL="http://localhost:18060/mcp"

# ---------- parse flags ----------
INCLUDE_ALL=false
for arg in "$@"; do
    case "$arg" in
        --all) INCLUDE_ALL=true ;;
        --help|-h)
            echo "Usage: ./deploy.sh [--all]"
            echo ""
            echo "  --all    Include optional MCPs without prompting and"
            echo "           keep all unmanaged entries in target configs."
            exit 0
            ;;
        *)
            echo "Unknown flag: $arg"
            echo "Usage: ./deploy.sh [--all]"
            exit 1
            ;;
    esac
done

# ---------- helpers ----------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m  +\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$1"; }
removed() { printf '\033[1;31m  -\033[0m %s\n' "$1"; }

# Prompt with a default of N. Returns 0 for yes, 1 for no.
confirm() {
    if $INCLUDE_ALL; then return 0; fi
    local prompt="$1"
    local reply
    printf '\033[1;33m  ?\033[0m %s [y/N] ' "$prompt"
    read -r reply
    case "$reply" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Ensure an HTTP MCP entry exists in a JSON config file.
ensure_http_mcp() {
python3 - "$1" "$2" "$3" <<'PYEOF'
import json, os, sys

mcp_path, name, url = sys.argv[1:4]

if os.path.exists(mcp_path):
    with open(mcp_path) as f:
        try:
            config = json.load(f)
        except json.JSONDecodeError:
            config = {}
else:
    config = {}

config.setdefault("mcpServers", {})
entry = {"type": "http", "url": url}

if config["mcpServers"].get(name) == entry:
    print(f"  = {name} (unchanged)")
    sys.exit(0)

config["mcpServers"][name] = entry
with open(mcp_path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")

print(f"  + {name}")
PYEOF
}

# ---------- 1. APM install ----------
info "Running apm install..."
(cd "$REPO_DIR" && apm install)

# APM generates a workspace Cursor MCP config, but this repo deploys a
# machine-wide Cursor config. Removing the workspace file avoids duplicate
# registrations when this repo is open in Cursor.
if [ -f "$WORKSPACE_CURSOR_MCP" ]; then
    rm -f "$WORKSPACE_CURSOR_MCP"
    ok "Removed workspace Cursor MCP config"
fi

# Xiaohongshu MCP: Go binary server (xpzouying/xiaohongshu-mcp), HTTP on localhost:18060
info "Checking xiaohongshu-mcp Go binary..."
if [ -x "$XHS_BIN" ]; then
    chmod +x "$REPO_DIR/scripts/xhs-start" "$REPO_DIR/scripts/xhs-relogin"
    ok "xiaohongshu-mcp binary found at $XHS_BIN"
    ok "Use 'scripts/xhs-relogin' to authenticate, 'scripts/xhs-start' to start the server"
else
    warn "xiaohongshu-mcp binary not found at $XHS_BIN"
    warn "Download from: https://github.com/xpzouying/xiaohongshu-mcp/releases"
    warn "Place darwin-arm64 binaries in $REPO_DIR/bin/ and chmod +x them"
fi

# ---------- 2. Resolve optional MCPs ----------
info "Resolving optional MCP servers..."

# Read optional MCP names from apm.yml
OPTIONAL_ACCEPTED=()
OPTIONAL_MCP_NAMES=()
while IFS= read -r line; do
    [ -n "$line" ] && OPTIONAL_MCP_NAMES+=("$line")
done < <(python3 - "$REPO_DIR/apm.yml" <<'PYEOF'
import sys, yaml
with open(sys.argv[1]) as f:
    apm = yaml.safe_load(f)
for s in apm.get("dependencies", {}).get("optional_mcp", []):
    print(s["name"])
PYEOF
)

for name in "${OPTIONAL_MCP_NAMES[@]}"; do
    if confirm "Include optional MCP: $name?"; then
        OPTIONAL_ACCEPTED+=("$name")
        ok "$name (included)"
    else
        warn "$name (skipped)"
    fi
done

# ---------- 3. Sync MCP servers to global configs ----------
for TARGET_MCP in "$CLAUDE_MCP" "$CURSOR_MCP" "$GEMINI_DIR/mcp_config.json"; do
info "Syncing MCP servers to $TARGET_MCP..."

# Build the comma-separated list of accepted optional MCPs for Python
OPTIONAL_CSV=""
for n in "${OPTIONAL_ACCEPTED[@]+"${OPTIONAL_ACCEPTED[@]}"}"; do
    if [ -n "$OPTIONAL_CSV" ]; then OPTIONAL_CSV="$OPTIONAL_CSV,$n"; else OPTIONAL_CSV="$n"; fi
done

python3 - "$REPO_DIR/apm.yml" "$TARGET_MCP" "$OPTIONAL_CSV" <<'PYEOF'
import sys, json, os
try:
    import yaml
except ImportError:
    print("  ! PyYAML not found, installing...", file=sys.stderr)
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "pyyaml"])
    import yaml

apm_path, mcp_path, optional_csv = sys.argv[1], sys.argv[2], sys.argv[3]
accepted_optional = set(optional_csv.split(",")) if optional_csv else set()

# Read apm.yml
with open(apm_path) as f:
    apm = yaml.safe_load(f)

deps = apm.get("dependencies", {})
mcp_servers = deps.get("mcp", [])
optional_servers = deps.get("optional_mcp", [])

# Combine core + accepted optional
all_servers = list(mcp_servers)
for s in optional_servers:
    if s["name"] in accepted_optional:
        all_servers.append(s)

if not all_servers:
    print("  No MCP servers to sync")
    sys.exit(0)

# Read existing config or create empty
if os.path.exists(mcp_path):
    with open(mcp_path) as f:
        try:
            mcp_config = json.load(f)
        except json.JSONDecodeError:
            mcp_config = {}
else:
    mcp_config = {}

if "mcpServers" not in mcp_config:
    mcp_config["mcpServers"] = {}

# Merge each server
added, skipped = [], []
for server in all_servers:
    name = server["name"]
    entry = {"command": server["command"], "args": server["args"]}
    if "env" in server:
        entry["env"] = server["env"]
    if "disabled" in server:
        entry["disabled"] = server["disabled"]

    if name in mcp_config["mcpServers"]:
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

# Output the set of managed names (one per line) on fd 3 for conflict detection
managed_names = [s["name"] for s in all_servers]
# Write managed names to a temp marker in the JSON (we'll use a different approach)
# Instead, print a special marker line that the shell script can parse
print("__MANAGED__:" + ",".join(managed_names))
PYEOF
done

if [ -x "$XHS_BIN" ]; then
info "Ensuring optional Xiaohongshu MCP config..."
ensure_http_mcp "$CLAUDE_MCP" "xiaohongshu-mcp" "$XHS_MCP_URL"
ensure_http_mcp "$CURSOR_MCP" "xiaohongshu-mcp" "$XHS_MCP_URL"
fi

# ---------- 4. Detect & resolve unmanaged MCP entries ----------
info "Checking for unmanaged MCP entries in target configs..."

# Build the full list of managed MCP names (core + accepted optional + xiaohongshu)
MANAGED_NAMES=()
CORE_NAMES=()
while IFS= read -r line; do
    [ -n "$line" ] && CORE_NAMES+=("$line")
done < <(python3 - "$REPO_DIR/apm.yml" <<'PYEOF'
import sys, yaml
with open(sys.argv[1]) as f:
    apm = yaml.safe_load(f)
for s in apm.get("dependencies", {}).get("mcp", []):
    print(s["name"])
PYEOF
)
MANAGED_NAMES+=("${CORE_NAMES[@]}")
MANAGED_NAMES+=("${OPTIONAL_ACCEPTED[@]+"${OPTIONAL_ACCEPTED[@]}"}")
# xiaohongshu-mcp is managed separately but should not be flagged
if [ -x "$XHS_BIN" ]; then
    MANAGED_NAMES+=("xiaohongshu-mcp")
fi

for TARGET_MCP in "$CLAUDE_MCP" "$CURSOR_MCP" "$GEMINI_DIR/mcp_config.json"; do
    [ -f "$TARGET_MCP" ] || continue

    # Build comma-separated managed list for Python
    MANAGED_CSV=""
    for n in "${MANAGED_NAMES[@]}"; do
        if [ -n "$MANAGED_CSV" ]; then MANAGED_CSV="$MANAGED_CSV,$n"; else MANAGED_CSV="$n"; fi
    done

    # Get unmanaged names
    UNMANAGED=()
    while IFS= read -r line; do
        [ -n "$line" ] && UNMANAGED+=("$line")
    done < <(python3 - "$TARGET_MCP" "$MANAGED_CSV" <<'PYEOF'
import sys, json
mcp_path, managed_csv = sys.argv[1], sys.argv[2]
managed = set(managed_csv.split(",")) if managed_csv else set()

with open(mcp_path) as f:
    try:
        config = json.load(f)
    except json.JSONDecodeError:
        sys.exit(0)

for name in config.get("mcpServers", {}):
    if name not in managed:
        print(name)
PYEOF
    )

    if [ ${#UNMANAGED[@]} -eq 0 ]; then
        ok "$(basename "$TARGET_MCP"): no unmanaged entries"
        continue
    fi

    warn "Unmanaged MCP servers in $TARGET_MCP:"
    for name in "${UNMANAGED[@]}"; do
        warn "  $name"
    done

    if $INCLUDE_ALL; then
        ok "Keeping all unmanaged entries (--all mode)"
        continue
    fi

    # Prompt: overwrite (remove all unmanaged) or keep or interactive
    printf '\033[1;33m  ?\033[0m What to do? [k]eep all / [r]emove all / [i]nteractive: '
    read -r action
    case "$action" in
        [rR])
            # Remove all unmanaged
            python3 - "$TARGET_MCP" "$(IFS=,; echo "${UNMANAGED[*]}")" <<'PYEOF'
import sys, json
mcp_path = sys.argv[1]
to_remove = set(sys.argv[2].split(","))
with open(mcp_path) as f:
    config = json.load(f)
for name in to_remove:
    config.get("mcpServers", {}).pop(name, None)
with open(mcp_path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
PYEOF
            for name in "${UNMANAGED[@]}"; do
                removed "Removed $name from $(basename "$TARGET_MCP")"
            done
            ;;
        [iI])
            # Interactive: prompt for each
            REMOVE_LIST=()
            for name in "${UNMANAGED[@]}"; do
                printf '\033[1;33m  ?\033[0m %s — [k]eep / [r]emove: ' "$name"
                read -r choice
                case "$choice" in
                    [rR]) REMOVE_LIST+=("$name") ;;
                    *) ok "Keeping $name" ;;
                esac
            done
            if [ ${#REMOVE_LIST[@]} -gt 0 ]; then
                python3 - "$TARGET_MCP" "$(IFS=,; echo "${REMOVE_LIST[*]}")" <<'PYEOF'
import sys, json
mcp_path = sys.argv[1]
to_remove = set(sys.argv[2].split(","))
with open(mcp_path) as f:
    config = json.load(f)
for name in to_remove:
    config.get("mcpServers", {}).pop(name, None)
with open(mcp_path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
PYEOF
                for name in "${REMOVE_LIST[@]}"; do
                    removed "Removed $name from $(basename "$TARGET_MCP")"
                done
            fi
            ;;
        *)
            ok "Keeping all unmanaged entries"
            ;;
    esac
done

# ---------- 5. Symlink skills globally ----------
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

# ---------- 5b. Detect unmanaged skill symlinks ----------
info "Checking for unmanaged skill symlinks..."

# Get managed skill names from the compiled output
MANAGED_CLAUDE_SKILLS=()
for skill_dir in "$REPO_DIR/.claude/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    MANAGED_CLAUDE_SKILLS+=("$(basename "$skill_dir")")
done

MANAGED_GITHUB_SKILLS=()
for skill_dir in "$REPO_DIR/.github/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    MANAGED_GITHUB_SKILLS+=("$(basename "$skill_dir")")
done

# Also count globally-installed skills (e.g. find-skills)
GLOBAL_SKILLS=()
if [ -d "$HOME/.agents/skills" ]; then
    for skill_dir in "$HOME/.agents/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        GLOBAL_SKILLS+=("$(basename "$skill_dir")")
    done
fi

check_unmanaged_skills() {
    local target_dir="$1"
    local label="$2"
    shift 2
    local managed=("$@")

    [ -d "$target_dir" ] || return 0

    local unmanaged=()
    for entry in "$target_dir"/*/; do
        [ -e "$entry" ] || continue
        local name
        name="$(basename "$entry")"
        local found=false
        for m in "${managed[@]+"${managed[@]}"}"; do
            if [ "$name" = "$m" ]; then found=true; break; fi
        done
        # Also check global skills
        for g in "${GLOBAL_SKILLS[@]+"${GLOBAL_SKILLS[@]}"}"; do
            if [ "$name" = "$g" ]; then found=true; break; fi
        done
        if ! $found; then
            unmanaged+=("$name")
        fi
    done

    if [ ${#unmanaged[@]} -eq 0 ]; then
        ok "$label: no unmanaged skills"
        return 0
    fi

    warn "Unmanaged skills in $target_dir:"
    for name in "${unmanaged[@]}"; do
        warn "  $name"
    done

    if $INCLUDE_ALL; then
        ok "Keeping all unmanaged skills (--all mode)"
        return 0
    fi

    printf '\033[1;33m  ?\033[0m What to do? [k]eep all / [r]emove all / [i]nteractive: '
    read -r action
    case "$action" in
        [rR])
            for name in "${unmanaged[@]}"; do
                rm -rf "${target_dir:?}/$name"
                removed "Removed $name from $label"
            done
            ;;
        [iI])
            for name in "${unmanaged[@]}"; do
                printf '\033[1;33m  ?\033[0m %s — [k]eep / [r]emove: ' "$name"
                read -r choice
                case "$choice" in
                    [rR])
                        rm -rf "${target_dir:?}/$name"
                        removed "Removed $name from $label"
                        ;;
                    *) ok "Keeping $name" ;;
                esac
            done
            ;;
        *)
            ok "Keeping all unmanaged skills"
            ;;
    esac
}

check_unmanaged_skills "$CLAUDE_DIR/skills" "Claude Code skills" "${MANAGED_CLAUDE_SKILLS[@]+"${MANAGED_CLAUDE_SKILLS[@]}"}"
check_unmanaged_skills "$CURSOR_DIR/skills" "Cursor skills" "${MANAGED_GITHUB_SKILLS[@]+"${MANAGED_GITHUB_SKILLS[@]}"}"
check_unmanaged_skills "$GEMINI_GLOBAL_SKILLS" "Antigravity skills" "${MANAGED_GITHUB_SKILLS[@]+"${MANAGED_GITHUB_SKILLS[@]}"}"

# ---------- 6. Install skills-CLI packages ----------
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
echo "  MCP servers synced to: $CLAUDE_MCP, $CURSOR_MCP, $GEMINI_DIR/mcp_config.json"
if [ ${#OPTIONAL_ACCEPTED[@]} -gt 0 ]; then
    echo "  Optional MCPs included: ${OPTIONAL_ACCEPTED[*]}"
fi
echo ""
echo "  Restart your AI IDEs to pick up the new skills and MCP servers."
