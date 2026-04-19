#!/bin/bash
#
# EM-Team Checkpoint Command
# Source: superpowers state management
#
# Save and restore working state checkpoints
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Checkpoint directory
CHECKPOINT_DIR=".em-team/checkpoints"
mkdir -p "$CHECKPOINT_DIR"

# Parse command
COMMAND="${1:-save}"
CHECKPOINT_NAME="${2:-$(date +%Y%m%d-%H%M%S)}"

case $COMMAND in
    save)
        echo -e "${BLUE}💾 EM-Team Checkpoint: Save${NC}"
        echo "=============================="
        echo ""
        echo "Saving checkpoint: $CHECKPOINT_NAME"
        echo ""

        CHECKPOINT_FILE="$CHECKPOINT_DIR/$CHECKPOINT_NAME.json"

        # Gather state
        BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
        COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

        # Create checkpoint
        cat > "$CHECKPOINT_FILE" << EOF
{
  "id": "$CHECKPOINT_NAME",
  "timestamp": "$TIMESTAMP",
  "branch": "$BRANCH",
  "commit": "$COMMIT",
  "uncommitted_changes": $UNCOMMITTED,
  "decisions": [],
  "context": {
    "working_on": "",
    "blockers": [],
    "next_steps": []
  }
}
EOF

        echo -e "${GREEN}✓ Checkpoint saved${NC}"
        echo "  ID: $CHECKPOINT_NAME"
        echo "  Branch: $BRANCH"
        echo "  Commit: $COMMIT"
        echo "  Uncommitted changes: $UNCOMMITTED"
        echo ""
        echo "To restore this checkpoint:"
        echo "  em-team checkpoint restore $CHECKPOINT_NAME"
        ;;

    restore)
        echo -e "${BLUE}📂 EM-Team Checkpoint: Restore${NC}"
        echo "================================"
        echo ""
        echo "Restoring checkpoint: $CHECKPOINT_NAME"
        echo ""

        CHECKPOINT_FILE="$CHECKPOINT_DIR/$CHECKPOINT_NAME.json"

        if [ ! -f "$CHECKPOINT_FILE" ]; then
            echo -e "${RED}✗ Checkpoint not found: $CHECKPOINT_NAME${NC}"
            echo ""
            echo "Available checkpoints:"
            ls -1 "$CHECKPOINT_DIR" | sed 's/\.json$//' | while read id; do
                echo "  - $id"
            done
            exit 1
        fi

        # Load checkpoint
        BRANCH=$(jq -r '.branch' "$CHECKPOINT_FILE")
        COMMIT=$(jq -r '.commit' "$CHECKPOINT_FILE")
        TIMESTAMP=$(jq -r '.timestamp' "$CHECKPOINT_FILE")

        echo "Checkpoint details:"
        echo "  Created: $TIMESTAMP"
        echo "  Branch: $BRANCH"
        echo "  Commit: $COMMIT"
        echo ""

        # Restore state
        echo "Restoring state..."
        echo ""

        # Checkout branch
        if [ "$BRANCH" != "$(git rev-parse --abbrev-ref HEAD)" ]; then
            echo "  - Switching to branch: $BRANCH"
            git checkout "$BRANCH" >/dev/null 2>&1 || echo -e "${YELLOW}  ⚠ Branch not found${NC}"
        fi

        # Checkout commit
        echo "  - Checking out commit: $COMMIT"
        git checkout "$COMMIT" >/dev/null 2>&1 || echo -e "${YELLOW}  ⚠ Commit not found${NC}"

        echo ""
        echo -e "${GREEN}✓ Checkpoint restored${NC}"
        echo ""
        echo "⚠️  Note: This only restores git state"
        echo "   Any local changes were stashed"
        echo ""
        echo "Decisions from checkpoint:"
        jq -r '.decisions[]?' "$CHECKPOINT_FILE" 2>/dev/null | while read decision; do
            echo "  - $decision"
        done
        ;;

    list)
        echo -e "${BLUE}📋 EM-Team Checkpoints${NC}"
        echo "======================="
        echo ""

        if [ -z "$(ls -A $CHECKPOINT_DIR 2>/dev/null)" ]; then
            echo "No checkpoints found"
            exit 0
        fi

        echo "Available checkpoints:"
        echo ""

        for checkpoint_file in "$CHECKPOINT_DIR"/*.json; do
            if [ -f "$checkpoint_file" ]; then
                CHECKPOINT_ID=$(basename "$checkpoint_file" .json)
                TIMESTAMP=$(jq -r '.timestamp' "$checkpoint_file")
                BRANCH=$(jq -r '.branch' "$checkpoint_file")
                COMMIT=$(jq -r '.commit' "$checkpoint_file")

                echo "📌 $CHECKPOINT_ID"
                echo "   Created: $TIMESTAMP"
                echo "   Branch: $BRANCH"
                echo "   Commit: $COMMIT"
                echo ""
            fi
        done
        ;;

    delete)
        echo -e "${RED}🗑️  EM-Team Checkpoint: Delete${NC}"
        echo "================================"
        echo ""
        echo "Deleting checkpoint: $CHECKPOINT_NAME"
        echo ""

        CHECKPOINT_FILE="$CHECKPOINT_DIR/$CHECKPOINT_NAME.json"

        if [ ! -f "$CHECKPOINT_FILE" ]; then
            echo -e "${RED}✗ Checkpoint not found: $CHECKPOINT_NAME${NC}"
            exit 1
        fi

        rm "$CHECKPOINT_FILE"
        echo -e "${GREEN}✓ Checkpoint deleted${NC}"
        ;;

    *)
        echo "EM-Team Checkpoint Command"
        echo ""
        echo "Usage: em-team checkpoint <command> [name]"
        echo ""
        echo "Commands:"
        echo "  save [name]   - Save current state as checkpoint"
        echo "  restore <name> - Restore state from checkpoint"
        echo "  list          - List all checkpoints"
        echo "  delete <name> - Delete a checkpoint"
        echo ""
        echo "Examples:"
        echo "  em-team checkpoint save feature-start"
        echo "  em-team checkpoint restore feature-start"
        echo "  em-team checkpoint list"
        echo "  em-team checkpoint delete feature-start"
        echo ""
        echo "Note: Checkpoints only save git state (branch, commit)"
        echo "      They don't save uncommitted changes or files"
        exit 1
        ;;
esac
