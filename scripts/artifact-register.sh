#!/bin/bash
# artifact-register.sh — Manage EM-Team skill artifacts
# Usage:
#   bash scripts/artifact-register.sh list [category]    — List exported artifacts
#   bash scripts/artifact-register.sh stats              — Show artifact statistics
#   bash scripts/artifact-register.sh recent [days]      — Show recent artifacts
#   bash scripts/artifact-register.sh by-skill <name>    — Find artifacts by skill
#   bash scripts/artifact-register.sh clean [days]       — Remove artifacts older than N days (default 90)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[artifacts]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

CATEGORIES="brainstorm specs plans reviews architecture security performance tests ux artifacts"

scan_artifacts() {
  local category="${1:-}"
  for cat in ${CATEGORIES}; do
    [[ -n "$category" && "$cat" != "$category" ]] && continue
    local dir="$PROJECT_ROOT/$cat"
    [[ ! -d "$dir" ]] && continue
    while IFS= read -r f; do
      [[ -z "$f" ]] && continue
      echo "$f"
    done < <(find "$dir" -maxdepth 1 -name '*.md')
  done
}

cmd_list() {
  local category="${1:-}"
  echo ""
  info "Exported artifacts${category:+ in category: $category}"
  echo ""

  local found=0
  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    local basename
    basename=$(basename "$filepath")
    local dir
    dir=$(dirname "$filepath")
    local cat
    cat=$(basename "$dir")
    # Extract title from frontmatter
    local title=""
    if head -5 "$filepath" | grep -q "^title:"; then
      title=$(head -10 "$filepath" | grep "^title:" | head -1 | sed 's/^title: *//')
    fi
    echo "  [$cat] ${basename}${title:+ — $title}"
    found=$((found + 1))
  done < <(scan_artifacts "$category")

  [[ $found -eq 0 ]] && warn "No artifacts found" || true
  echo ""
}

cmd_stats() {
  echo ""
  info "Artifact statistics"
  echo ""

  local total=0
  for cat in ${CATEGORIES}; do
    local dir="$PROJECT_ROOT/$cat"
    [[ ! -d "$dir" ]] && continue
    local count
    count=$(find "$dir" -maxdepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -gt 0 ]]; then
      echo "  $cat: $count files"
    fi
    total=$((total + count))
  done

  echo ""
  echo "  Total: $total artifacts"
  echo ""
}

cmd_recent() {
  local days="${1:-7}"
  echo ""
  info "Recent artifacts (last $days days)"
  echo ""

  local cutoff
  cutoff=$(date -v-${days}d +%Y%m%d 2>/dev/null || date -d "$days days ago" +%Y%m%d)

  local found=0
  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    local basename
    basename=$(basename "$filepath")
    # Extract date prefix from filename (YYYY-MM-DD-HHMM)
    local file_date
    file_date=$(echo "$basename" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | tr -d '-' || true)
    [[ -z "$file_date" ]] && continue
    if [[ "$file_date" -ge "$cutoff" ]]; then
      local cat
      cat=$(basename "$(dirname "$filepath")")
      echo "  [$cat] $basename"
      found=$((found + 1))
    fi
  done < <(scan_artifacts)

  [[ $found -eq 0 ]] && warn "No recent artifacts" || true
  echo ""
}

cmd_by_skill() {
  local skill="$1"
  echo ""
  info "Artifacts from skill: $skill"
  echo ""

  local found=0
  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    if head -10 "$filepath" | grep -q "skill: $skill"; then
      local basename
      basename=$(basename "$filepath")
      local cat
      cat=$(basename "$(dirname "$filepath")")
      echo "  [$cat] $basename"
      found=$((found + 1))
    fi
  done < <(scan_artifacts)

  [[ $found -eq 0 ]] && warn "No artifacts found for skill: $skill" || true
  echo ""
}

cmd_clean() {
  local days="${1:-90}"
  echo ""
  info "Cleaning artifacts older than $days days..."

  local cutoff
  cutoff=$(date -v-${days}d +%Y%m%d 2>/dev/null || date -d "$days days ago" +%Y%m%d)
  local removed=0

  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    local basename
    basename=$(basename "$filepath")
    local file_date
    file_date=$(echo "$basename" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' | tr -d '-' || true)
    [[ -z "$file_date" ]] && continue
    if [[ "$file_date" -lt "$cutoff" ]]; then
      rm "$filepath"
      removed=$((removed + 1))
    fi
  done < <(scan_artifacts)

  ok "Removed $removed old artifacts"
  echo ""
}

# ─── Main ───
case "${1:-list}" in
  list)     cmd_list "${2:-}" ;;
  stats)    cmd_stats ;;
  recent)   cmd_recent "${2:-7}" ;;
  by-skill) cmd_by_skill "${2:-brainstorming}" ;;
  clean)    cmd_clean "${2:-90}" ;;
  *)
    echo "Usage: bash scripts/artifact-register.sh {list|stats|recent|by-skill|clean}"
    exit 1
    ;;
esac
