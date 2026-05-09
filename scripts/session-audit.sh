#!/bin/bash
# session-audit.sh — Manage EM-Team session audit logs
# Usage:
#   bash scripts/session-audit.sh status          — Show audit status and toggle
#   bash scripts/session-audit.sh stats [days]    — Show statistics (default 30 days)
#   bash scripts/session-audit.sh recent [days]   — Show recent entries (default 7)
#   bash scripts/session-audit.sh by-skill <name>  — Find entries by skill name
#   bash scripts/session-audit.sh rotate [days]   — Rotate logs older than N days (default 30)
#   bash scripts/session-audit.sh enable          — Show how to enable audit logging
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/.em-team/logs"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${CYAN}[audit]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

cmd_status() {
  echo ""
  echo "  EM-Team Session Audit"
  echo "  ─────────────────────"
  echo ""
  echo "  Toggle:  EM_TEAM_SESSION_AUDIT=${EM_TEAM_SESSION_AUDIT:-not set}"
  echo "  Log dir: $LOG_DIR"

  if [[ "${EM_TEAM_SESSION_AUDIT:-}" == "true" ]]; then
    ok "Audit logging is ENABLED"
  else
    warn "Audit logging is DISABLED"
    echo ""
    echo "  To enable, add to .claude/settings.local.json:"
    echo '    "env": { "EM_TEAM_SESSION_AUDIT": "true" }'
  fi

  if [[ -d "$LOG_DIR" ]]; then
    local count
    count=$(find "$LOG_DIR" -name 'audit-*.jsonl' -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
    echo "  Log files: $(ls "$LOG_DIR"/audit-*.jsonl 2>/dev/null | wc -l | tr -d ' ')"
    echo "  Total entries: $count"
  else
    echo "  No logs directory yet"
  fi
  echo ""
}

cmd_stats() {
  local days="${1:-30}"
  echo ""
  info "Audit statistics (last $days days)"
  echo ""

  if [[ ! -d "$LOG_DIR" ]]; then
    warn "No audit logs found"
    return
  fi

  local total=0
  local by_type_user=0 by_type_assistant=0 by_type_system=0 by_type_skill=0

  for f in "$LOG_DIR"/audit-*.jsonl; do
    [[ ! -f "$f" ]] && continue
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      total=$((total + 1))
      case "$line" in
        *'"type":"user"'*) by_type_user=$((by_type_user + 1)) ;;
        *'"type":"assistant"'*) by_type_assistant=$((by_type_assistant + 1)) ;;
        *'"type":"system"'*) by_type_system=$((by_type_system + 1)) ;;
        *'"type":"skill_start"'*|*'"type":"skill_end"'*) by_type_skill=$((by_type_skill + 1)) ;;
      esac
    done < "$f"
  done

  echo "  Total entries:  $total"
  echo "  User messages:  $by_type_user"
  echo "  AI responses:   $by_type_assistant"
  echo "  Skill events:   $by_type_skill"
  echo "  System events:  $by_type_system"
  echo ""
}

cmd_recent() {
  local days="${1:-7}"
  local count="${2:-20}"
  echo ""
  info "Recent audit entries (last $days days, showing $count)"
  echo ""

  if [[ ! -d "$LOG_DIR" ]]; then
    warn "No audit logs found"
    return
  fi

  local shown=0
  for f in "$LOG_DIR"/audit-*.jsonl; do
    [[ ! -f "$f" ]] && continue
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      local ts type content
      ts=$(echo "$line" | grep -oE '"ts":"[^"]+"' | head -1 | cut -d'"' -f4)
      type=$(echo "$line" | grep -oE '"type":"[^"]+"' | head -1 | cut -d'"' -f4)
      content=$(echo "$line" | grep -oE '"content":"[^"]{0,80}' | head -1 | cut -d'"' -f4)
      echo "  [$ts] ($type) ${content:0:80}"
      shown=$((shown + 1))
      [[ $shown -ge $count ]] && break
    done < "$f"
    [[ $shown -ge $count ]] && break
  done
  echo ""
}

cmd_by_skill() {
  local skill="$1"
  echo ""
  info "Entries for skill: $skill"
  echo ""

  if [[ ! -d "$LOG_DIR" ]]; then
    warn "No audit logs found"
    return
  fi

  local found=0
  for f in "$LOG_DIR"/audit-*.jsonl; do
    [[ ! -f "$f" ]] && continue
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      if echo "$line" | grep -q "\"skill\":\"$skill\""; then
        local ts type content
        ts=$(echo "$line" | grep -oE '"ts":"[^"]+"' | head -1 | cut -d'"' -f4)
        type=$(echo "$line" | grep -oE '"type":"[^"]+"' | head -1 | cut -d'"' -f4)
        content=$(echo "$line" | grep -oE '"content":"[^"]{0,80}' | head -1 | cut -d'"' -f4)
        echo "  [$ts] ($type) ${content:0:80}"
        found=$((found + 1))
      fi
    done < "$f"
  done

  [[ $found -eq 0 ]] && warn "No entries found for skill: $skill"
  echo ""
}

cmd_rotate() {
  local days="${1:-30}"
  echo ""
  info "Rotating logs older than $days days..."

  local archive_dir="$LOG_DIR/archive"
  mkdir -p "$archive_dir"

  local cutoff
  cutoff=$(date -v-${days}d +%Y-%m-%d 2>/dev/null || date -d "$days days ago" +%Y-%m-%d)
  local rotated=0

  for f in "$LOG_DIR"/audit-*.jsonl; do
    [[ ! -f "$f" ]] && continue
    local basename
    basename=$(basename "$f")
    local file_date="${basename#audit-}"
    file_date="${file_date%.jsonl}"
    if [[ "$file_date" < "$cutoff" ]]; then
      mv "$f" "$archive_dir/$basename"
      rotated=$((rotated + 1))
    fi
  done

  ok "Rotated $rotated log files to archive/"
  echo ""
}

cmd_enable() {
  echo ""
  echo "  To enable session audit logging, add to .claude/settings.local.json:"
  echo ""
  echo '  {'
  echo '    "env": {'
  echo '      "EM_TEAM_SESSION_AUDIT": "true"'
  echo '    }'
  echo '  }'
  echo ""
  echo "  Then restart Claude Code."
  echo ""
}

# ─── Main ───
case "${1:-status}" in
  status)   cmd_status ;;
  stats)    cmd_stats "${2:-30}" ;;
  recent)   cmd_recent "${2:-7}" "${3:-20}" ;;
  by-skill) cmd_by_skill "${2:-brainstorming}" ;;
  rotate)   cmd_rotate "${2:-30}" ;;
  enable)   cmd_enable ;;
  *)
    echo "Usage: bash scripts/session-audit.sh {status|stats|recent|by-skill|rotate|enable}"
    exit 1
    ;;
esac
