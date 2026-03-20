#!/usr/bin/env bash

set -e

SKILL_NAME=$1
IDE_NAME=$2
IS_GLOBAL=false

if [[ -z "$SKILL_NAME" || -z "$IDE_NAME" ]]; then
  echo "Usage: $0 <skill_name> <cursor|claude|antigravity> [--global]"
  echo "Example: $0 project-init-iterate cursor --global"
  exit 1
fi

if [[ "$3" == "--global" || "$4" == "--global" ]]; then
  IS_GLOBAL=true
fi

if [[ ! -d "$SKILL_NAME" ]]; then
  echo "Error: Skill directory '$SKILL_NAME' does not exist."
  exit 1
fi

DEST_DIR=""

case "$IDE_NAME" in
  cursor)
    if [[ "$IS_GLOBAL" == true ]]; then
      DEST_DIR="$HOME/.cursor/skills/$SKILL_NAME"
    else
      DEST_DIR=".cursor/skills/$SKILL_NAME"
    fi
    ;;
  claude)
    if [[ "$IS_GLOBAL" == true ]]; then
      DEST_DIR="$HOME/.claude/skills/$SKILL_NAME"
    else
      DEST_DIR=".claude/skills/$SKILL_NAME"
    fi
    ;;
  antigravity)
    if [[ "$IS_GLOBAL" == true ]]; then
      DEST_DIR="$HOME/.gemini/antigravity/skills/$SKILL_NAME"
    else
      DEST_DIR=".agent/skills/$SKILL_NAME"
    fi
    ;;
  *)
    echo "Error: Unsupported IDE '$IDE_NAME'."
    echo "Supported options: cursor, claude, antigravity"
    exit 1
    ;;
esac

echo "🚀 Installing $SKILL_NAME for $IDE_NAME..."
mkdir -p "$(dirname "$DEST_DIR")"

# Remove existing dir if it exists to ensure a clean overwrite
if [[ -d "$DEST_DIR" ]]; then
  rm -rf "$DEST_DIR"
fi

cp -r "$SKILL_NAME" "$DEST_DIR"

echo "✅ Successfully installed to $DEST_DIR!"

if [[ "$IDE_NAME" == "claude" ]]; then
  echo ""
  echo "📌 Note for Claude Code users: Claude Code primarily uses CLAUDE.md."
  echo "Make sure to reference this skill in your CLAUDE.md file by adding:"
  echo "--------------------------------------------------------"
  echo "To use the $SKILL_NAME skill, refer to the instructions in:"
  if [[ "$IS_GLOBAL" == true ]]; then
    echo "~/.claude/skills/$SKILL_NAME/SKILL.md"
  else
    echo "./.claude/skills/$SKILL_NAME/SKILL.md"
  fi
  echo "--------------------------------------------------------"
fi
