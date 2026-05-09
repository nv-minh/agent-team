#!/bin/bash
# install.sh — Install EM-Team globally for Claude Code (GSD-style)
# Copies content + creates /em/* slash commands. No symlinks.
# Usage: bash install.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CONTENT_DIR="$CLAUDE_DIR/em-team"
COMMANDS_DIR="$CLAUDE_DIR/commands/em"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[install]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║       EM-Team v3.2.0 Installer       ║"
echo "  ╚══════════════════════════════════════╝"
echo ""

# ─── Step 1: Verify repo ───
if [[ ! -f "$REPO/CLAUDE.md" ]]; then
  err "Not an EM-Team repo (missing CLAUDE.md). Run from EM-Team root."
fi

info "Repo: $REPO"
info "Target: $CLAUDE_DIR"
echo ""

# ─── Step 2: Clean old installs ───
info "Cleaning old installs ..."

# Remove old content directory
if [[ -d "$CONTENT_DIR" ]]; then
  rm -rf "$CONTENT_DIR"
  ok "Removed old ~/.claude/em-team/"
fi

# Remove old command directory
if [[ -d "$COMMANDS_DIR" ]]; then
  rm -rf "$COMMANDS_DIR"
  ok "Removed old ~/.claude/commands/em/"
fi

# Remove old skill symlinks (em:* and em-* directories with SKILL.md)
OLD_SKILLS=$(find "$CLAUDE_DIR/skills" -mindepth 1 -maxdepth 1 -type d -name 'em:*' -o -name 'em-*' 2>/dev/null || true)
if [[ -n "$OLD_SKILLS" ]]; then
  echo "$OLD_SKILLS" | while read -r dir; do
    rm -rf "$dir"
  done
  COUNT=$(echo "$OLD_SKILLS" | wc -l | tr -d ' ')
  ok "Removed $COUNT old skill directories"
fi

# Remove old config.json entries (skills/agents/workflows paths)
CONFIG="$CLAUDE_DIR/config.json"
if [[ -f "$CONFIG" ]] && command -v python3 &>/dev/null; then
  python3 - "$CONFIG" <<'PYEOF'
import json, sys
config_path = sys.argv[1]
try:
    with open(config_path) as f:
        cfg = json.load(f)
except Exception:
    cfg = {}
changed = False
for key in ['skills', 'agents', 'workflows']:
    if key in cfg:
        del cfg[key]
        changed = True
if changed:
    with open(config_path, 'w') as f:
        json.dump(cfg, f, indent=2)
        f.write('\n')
PYEOF
  ok "Cleaned old config.json entries"
fi

# ─── Step 3: Copy content to ~/.claude/em-team/ ───
info "Copying content to ~/.claude/em-team/ ..."

mkdir -p "$CONTENT_DIR"

# Copy agents, workflows, preambles, protocols, references
cp -R "$REPO/agents"       "$CONTENT_DIR/agents"
cp -R "$REPO/workflows"    "$CONTENT_DIR/workflows"
cp -R "$REPO/preambles"    "$CONTENT_DIR/preambles"
cp -R "$REPO/protocols"    "$CONTENT_DIR/protocols" 2>/dev/null || true
cp -R "$REPO/references"   "$CONTENT_DIR/references" 2>/dev/null || true

# Copy lib (session-audit, artifact-store, trace-store)
mkdir -p "$CONTENT_DIR/lib"
cp "$REPO/.claude/lib/session-audit.ts"   "$CONTENT_DIR/lib/" 2>/dev/null || true
cp "$REPO/.claude/lib/artifact-store.ts"  "$CONTENT_DIR/lib/" 2>/dev/null || true
cp "$REPO/.claude/lib/trace-store.ts"     "$CONTENT_DIR/lib/" 2>/dev/null || true

# Copy scripts (session-audit, artifact-register)
mkdir -p "$CONTENT_DIR/scripts"
cp "$REPO/scripts/session-audit.sh"       "$CONTENT_DIR/scripts/" 2>/dev/null || true
cp "$REPO/scripts/artifact-register.sh"   "$CONTENT_DIR/scripts/" 2>/dev/null || true

# Copy skills (flatten to skills/<name>/<name>.md structure)
mkdir -p "$CONTENT_DIR/skills"
find "$REPO/skills" -name '*.md' -not -name 'SKILL.md' | while read -r src; do
  # Get just the filename (e.g., brainstorming.md)
  filename=$(basename "$src")
  # Create a flat directory
  mkdir -p "$CONTENT_DIR/skills"
  # Preserve category structure
  relpath=${src#$REPO/skills/}
  destdir=$(dirname "$CONTENT_DIR/skills/$relpath")
  mkdir -p "$destdir"
  cp "$src" "$destdir/$filename"
done

AGENT_COUNT=$(ls "$CONTENT_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
WORKFLOW_COUNT=$(ls "$CONTENT_DIR/workflows/"*.md 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(find "$CONTENT_DIR/skills" -name '*.md' | wc -l | tr -d ' ')

ok "Content copied:"
ok "  $AGENT_COUNT agents"
ok "  $WORKFLOW_COUNT workflows"
ok "  $SKILL_COUNT skills"

# ─── Step 4: Create command wrappers ───
info "Creating slash commands in ~/.claude/commands/em/ ..."

mkdir -p "$COMMANDS_DIR"

CMD_COUNT=0

# Helper: resolve wrapper's "## Source" to get actual skill file path
resolve_source_path() {
  local wrapper="$1"
  grep -A2 '## Source' "$wrapper" | grep -oE '`[^`]+\.md`' | head -1 | tr -d '`'
}

# --- Agent commands ---
# Wrapper em-X.md → look for agents/X.md
for wrapper in "$REPO/.claude/skills/"em-*.md; do
  [[ ! -f "$wrapper" ]] && continue
  basename=$(basename "$wrapper" .md)    # e.g., em-planner
  name="${basename#em-}"                  # e.g., planner

  # Skip skill wrappers (handled separately)
  [[ "$name" == skill-* ]] && continue

  # Determine source: agent or workflow?
  source_file=""
  if [[ -f "$CONTENT_DIR/agents/$name.md" ]]; then
    source_file="agents/$name.md"
  elif [[ -f "$CONTENT_DIR/workflows/$name.md" ]]; then
    source_file="workflows/$name.md"
  else
    # Try alias: search agents/ and workflows/ by filename
    found=$(find "$CONTENT_DIR/agents" "$CONTENT_DIR/workflows" -name "$name.md" 2>/dev/null | head -1)
    if [[ -n "$found" ]]; then
      source_file="${found#$CONTENT_DIR/}"
    fi
  fi

  if [[ -n "$source_file" ]]; then
    # Get description from wrapper frontmatter
    desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
    [[ -z "$desc" ]] && desc="$name"

    cat > "$COMMANDS_DIR/$name.md" <<CMD
---
name: em-$name
description: $desc
---
<execution_context>
@\$HOME/.claude/em-team/$source_file
</execution_context>
CMD
    CMD_COUNT=$((CMD_COUNT + 1))
  fi
done

# --- Skill commands ---
# Wrapper em-skill-X.md → resolve source path
for wrapper in "$REPO/.claude/skills/"em-skill-*.md; do
  [[ ! -f "$wrapper" ]] && continue
  basename=$(basename "$wrapper" .md)    # e.g., em-skill-brainstorming
  name="${basename#em-skill-}"            # e.g., brainstorming

  # Resolve source path from wrapper (e.g., "skills/foundation/brainstorming/brainstorming.md")
  rel_source=$(resolve_source_path "$wrapper")

  if [[ -n "$rel_source" ]] && [[ -f "$CONTENT_DIR/$rel_source" ]]; then
    source_file="$rel_source"
  else
    # Fallback: try flat name
    if [[ -f "$CONTENT_DIR/skills/$name.md" ]]; then
      source_file="skills/$name.md"
    else
      # Try finding by filename anywhere in skills/
      found=$(find "$CONTENT_DIR/skills" -name "$name.md" | head -1)
      if [[ -n "$found" ]]; then
        source_file="${found#$CONTENT_DIR/}"
      else
        continue
      fi
    fi
  fi

  desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
  [[ -z "$desc" ]] && desc="$name"

  cat > "$COMMANDS_DIR/$name.md" <<CMD
---
name: em-skill-$name
description: $desc
---
<execution_context>
@\$HOME/.claude/em-team/$source_file
</execution_context>
CMD
  CMD_COUNT=$((CMD_COUNT + 1))
done

# --- Alias shortcuts ---
# Short names that map to longer agent/workflow names
for pair in \
  "backend:backend-expert" "frontend:frontend-expert" "debug:debugger" \
  "security:security-auditor" "ship:ship-workflow" "team:team-lead" \
  "test:test-engineer" "verify:verifier" "database:database-expert" \
  "incident:incident-response" "performance:performance-auditor" \
  "refactor:refactoring" "research:researcher" \
  "distributed:distributed-investigation" "code-review-deep:code-review-9axis"; do
  alias="${pair%%:*}"
  target="${pair##*:}"

  # Skip if alias already exists as a command
  [[ -f "$COMMANDS_DIR/$alias.md" ]] && continue

  if [[ -f "$CONTENT_DIR/agents/$target.md" ]]; then
    source_file="agents/$target.md"
  elif [[ -f "$CONTENT_DIR/workflows/$target.md" ]]; then
    source_file="workflows/$target.md"
  else
    continue
  fi

  desc=$(grep '^description:' "$REPO/.claude/skills/em-$alias.md" 2>/dev/null | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
  [[ -z "$desc" ]] && desc="Shortcut for $target"

  cat > "$COMMANDS_DIR/$alias.md" <<CMD
---
name: em-$alias
description: $desc
---
<execution_context>
@\$HOME/.claude/em-team/$source_file
</execution_context>
CMD
  CMD_COUNT=$((CMD_COUNT + 1))
done

# --- Standalone command shortcuts (qa, quick, health, checkpoint) ---
# These are thin commands without a separate source file
for name in qa quick health checkpoint; do
  wrapper="$REPO/.claude/skills/em-$name.md"
  [[ ! -f "$wrapper" ]] && continue
  [[ -f "$COMMANDS_DIR/$name.md" ]] && continue

  desc=$(grep '^description:' "$wrapper" | head -1 | sed 's/^description: *//' | sed 's/^"//' | sed 's/"$//')
  [[ -z "$desc" ]] && desc="$name"

  # Copy wrapper content as the full command (it's self-contained)
  cat > "$COMMANDS_DIR/$name.md" <<CMD
---
name: em-$name
description: $desc
---
CMD
  # Append the rest of the wrapper (after frontmatter)
  sed '1,/^---$/d' "$wrapper" | sed '1,/^---$/d' >> "$COMMANDS_DIR/$name.md"
  CMD_COUNT=$((CMD_COUNT + 1))
done

ok "Created $CMD_COUNT slash commands"

# ─── Step 5: Verify ───
echo ""
info "Verifying installation ..."
echo ""

ERRORS=0

# Check content exists
if [[ -d "$CONTENT_DIR/agents" && -d "$CONTENT_DIR/workflows" && -d "$CONTENT_DIR/skills" ]]; then
  ok "  Content directory: $CONTENT_DIR"
else
  warn "  Content directory incomplete"
  ERRORS=$((ERRORS + 1))
fi

# Check commands exist
CMD_TOTAL=$(ls "$COMMANDS_DIR/"*.md 2>/dev/null | wc -l | tr -d ' ')
if [[ "$CMD_TOTAL" -gt 0 ]]; then
  ok "  $CMD_TOTAL slash commands in $COMMANDS_DIR"
else
  warn "  No slash commands created"
  ERRORS=$((ERRORS + 1))
fi

# Check a sample command has valid @file reference
SAMPLE="$COMMANDS_DIR/planner.md"
if [[ -f "$SAMPLE" ]]; then
  if grep -q '@.*/em-team/' "$SAMPLE"; then
    ok "  @file references valid"
  else
    warn "  @file reference missing in planner.md"
    ERRORS=$((ERRORS + 1))
  fi
fi

# Check lib files
LIB_COUNT=$(ls "$CONTENT_DIR/lib/"*.ts 2>/dev/null | wc -l | tr -d ' ')
if [[ "$LIB_COUNT" -gt 0 ]]; then
  ok "  $LIB_COUNT lib files (session-audit, artifact-store, trace-store)"
else
  warn "  No lib files copied"
fi

# ─── Summary ───
echo ""
if [[ $ERRORS -eq 0 ]]; then
  echo -e "  ${GREEN}Installation complete!${NC}"
  echo ""
  echo "  Installed:"
  echo "    Content:  $CONTENT_DIR/ ($AGENT_COUNT agents, $WORKFLOW_COUNT workflows, $SKILL_COUNT skills)"
  echo "    Commands: $COMMANDS_DIR/ ($CMD_TOTAL slash commands)"
  echo ""
  echo "  Next steps:"
  echo "    1. Restart Claude Code"
  echo "    2. Type /em- to see all EM-Team commands"
  echo "    3. Try: /em-planner Create implementation plan"
  echo "    4. Try: /em-skill-brainstorming Explore feature ideas"
  echo ""
  echo "  To uninstall: bash $REPO/uninstall.sh"
else
  echo -e "  ${YELLOW}Installed with $ERRORS warnings.${NC}"
fi
echo ""
