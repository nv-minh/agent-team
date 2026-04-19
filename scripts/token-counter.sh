#!/usr/bin/env bash
# Token Counter for EM-Team Distributed Mode
# Estimates token counts using tiktoken or character-based fallback

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/token-config.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[TOKEN-COUNTER]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[TOKEN-COUNTER]${NC} $1"
}

log_error() {
    echo -e "${RED}[TOKEN-COUNTER]${NC} $1"
}

# Load configuration if exists
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    else
        # Default values
        TOKEN_BUDGET=${TOKEN_BUDGET:-200000}
        SAFETY_MARGIN=${SAFETY_MARGIN:-50000}
        SUMMARIZATION_THRESHOLD=${SUMMARIZATION_THRESHOLD:-150000}
        TARGET_SUMMARY_SIZE=${TARGET_SUMMARY_SIZE:-80000}
        MIN_SUMMARY_SIZE=${MIN_SUMMARY_SIZE:-50000}
        MAX_SUMMARY_SIZE=${MAX_SUMMARY_SIZE:-100000}
    fi
}

# Check if tiktoken is available
check_tiktoken() {
    if command -v python3 &> /dev/null; then
        if python3 -c "import tiktoken" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Count tokens using tiktoken (accurate method)
count_tokens_tiktoken() {
    local text="$1"
    local encoding=${2:-"cl100k_base"}  # GPT-4 encoding (closest to Claude)

    if ! check_tiktoken; then
        log_warn "tiktoken not available, using fallback"
        return 1
    fi

    # Use tiktoken for accurate counting
    python3 -c "
import tiktoken
import sys

try:
    encoding = tiktoken.get_encoding('$encoding')
    text = sys.stdin.read()
    tokens = encoding.encode(text)
    print(len(tokens))
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" <<< "$text"
}

# Count tokens using character-based estimation (fallback)
count_tokens_fallback() {
    local text="$1"
    local chars_per_token=${2:-4}

    # Count characters and divide by average chars per token
    local char_count=$(echo -n "$text" | wc -c | tr -d ' ')
    local token_count=$((char_count / chars_per_token))

    echo "$token_count"
}

# Estimate token count for a file
estimate_tokens() {
    local file_path="$1"
    local method=${2:-"auto"}

    if [[ ! -f "$file_path" ]]; then
        log_error "File not found: $file_path"
        return 1
    fi

    # Read file content
    local content
    content=$(cat "$file_path")

    # Count tokens based on method
    local token_count
    if [[ "$method" == "tiktoken" ]] || { [[ "$method" == "auto" ]] && check_tiktoken; }; then
        token_count=$(count_tokens_tiktoken "$content")
        if [[ -n "$token_count" ]]; then
            echo "$token_count"
            return 0
        fi
    fi

    # Fallback to character-based estimation
    token_count=$(count_tokens_fallback "$content")
    echo "$token_count"
}

# Format token count for display
format_tokens() {
    local count=$1

    if [[ $count -ge 1000000 ]]; then
        echo "$(awk "BEGIN {printf \"%.1fM\", $count/1000000}")"
    elif [[ $count -ge 1000 ]]; then
        echo "$(awk "BEGIN {printf \"%.1fK\", $count/1000}")"
    else
        echo "$count"
    fi
}

# Check if file exceeds threshold
check_threshold() {
    local file_path="$1"
    local threshold=${2:-"$SUMMARIZATION_THRESHOLD"}

    load_config

    local token_count=$(estimate_tokens "$file_path")

    if [[ $token_count -gt $threshold ]]; then
        log_warn "File exceeds threshold: $(format_tokens $token_count) > $(format_tokens $threshold)"
        return 0
    else
        log_info "File within threshold: $(format_tokens $token_count) <= $(format_tokens $threshold)"
        return 1
    fi
}

# Get token statistics for a directory
get_dir_stats() {
    local dir_path="$1"
    local pattern=${2:-"*.md"}

    if [[ ! -d "$dir_path" ]]; then
        log_error "Directory not found: $dir_path"
        return 1
    fi

    load_config

    local total_tokens=0
    local file_count=0
    local max_tokens=0
    local max_file=""

    while IFS= read -r -d '' file; do
        local tokens=$(estimate_tokens "$file")
        total_tokens=$((total_tokens + tokens))
        file_count=$((file_count + 1))

        if [[ $tokens -gt $max_tokens ]]; then
            max_tokens=$tokens
            max_file="$file"
        fi

        echo "  $(format_tokens $tokens) - $file"
    done < <(find "$dir_path" -name "$pattern" -type f -print0)

    echo ""
    echo "Summary:"
    echo "  Total files: $file_count"
    echo "  Total tokens: $(format_tokens $total_tokens)"
    echo "  Average: $(format_tokens $((total_tokens / file_count)))"
    echo "  Largest: $(format_tokens $max_tokens) - $max_file"
}

# Compare token count to budget
compare_to_budget() {
    local file_path="$1"
    local budget=${2:-"$TOKEN_BUDGET"}

    load_config

    local token_count=$(estimate_tokens "$file_path")
    local percentage=$((token_count * 100 / budget))

    echo "Token Count Analysis:"
    echo "  File: $file_path"
    echo "  Tokens: $(format_tokens $token_count)"
    echo "  Budget: $(format_tokens $budget)"
    echo "  Usage: ${percentage}%"

    if [[ $token_count -gt $budget ]]; then
        log_error "EXCEEDS BUDGET by $(format_tokens $((token_count - budget)))"
        return 1
    elif [[ $token_count -gt $((budget - SAFETY_MARGIN)) ]]; then
        log_warn "Approaching budget limit"
        return 0
    else
        log_info "Within budget"
        return 0
    fi
}

# Main entry point
main() {
    load_config

    case "${1:-}" in
        estimate)
            if [[ -z "${2:-}" ]]; then
                log_error "Usage: $0 estimate <file> [method]"
                echo "Methods: auto (default), tiktoken, fallback"
                exit 1
            fi
            estimate_tokens "$2" "${3:-auto}"
            ;;
        check)
            if [[ -z "${2:-}" ]]; then
                log_error "Usage: $0 check <file> [threshold]"
                exit 1
            fi
            check_threshold "$2" "${3:-$SUMMARIZATION_THRESHOLD}"
            ;;
        dir-stats)
            if [[ -z "${2:-}" ]]; then
                log_error "Usage: $0 dir-stats <dir> [pattern]"
                exit 1
            fi
            get_dir_stats "$2" "${3:-*.md}"
            ;;
        compare)
            if [[ -z "${2:-}" ]]; then
                log_error "Usage: $0 compare <file> [budget]"
                exit 1
            fi
            compare_to_budget "$2" "${3:-$TOKEN_BUDGET}"
            ;;
        test-tiktoken)
            if check_tiktoken; then
                log_info "tiktoken is available"
                echo "Test: 'Hello, world!' → $(echo "Hello, world!" | count_tokens_tiktoken) tokens"
            else
                log_error "tiktoken is not available"
                exit 1
            fi
            ;;
        *)
            echo "Usage: $0 {estimate|check|dir-stats|compare|test-tiktoken}"
            echo ""
            echo "Commands:"
            echo "  estimate <file> [method]    - Estimate token count (auto/tiktoken/fallback)"
            echo "  check <file> [threshold]    - Check if file exceeds threshold"
            echo "  dir-stats <dir> [pattern]   - Get statistics for directory"
            echo "  compare <file> [budget]     - Compare token count to budget"
            echo "  test-tiktoken                - Test tiktoken availability"
            echo ""
            echo "Examples:"
            echo "  $0 estimate report.md"
            echo "  $0 check report.md 150000"
            echo "  $0 dir-stats /tmp/reports"
            echo "  $0 compare consolidated.md 200000"
            exit 1
            ;;
    esac
}

# If script is executed (not sourced), run main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
