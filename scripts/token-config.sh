#!/bin/bash
# Token Configuration for EM-Team Distributed Mode
# Defines thresholds and budgets for token management

################################################################################
# Token Thresholds
################################################################################

# Tech Lead's total token budget
TOKEN_BUDGET=200000

# Safety margin to stay under budget
SAFETY_MARGIN=50000

# Trigger summarization when reports exceed this threshold
SUMMARIZATION_THRESHOLD=150000

################################################################################
# Summarization Targets
################################################################################

# Aim for this token count after summarization
TARGET_SUMMARY_SIZE=80000

# Minimum acceptable size after summarization
MIN_SUMMARY_SIZE=50000

# Maximum acceptable size after summarization
MAX_SUMMARY_SIZE=100000

################################################################################
# Model Configuration
################################################################################

# Haiku model for summarization
HAIKU_MODEL="claude-3-5-haiku-20241022"

# Maximum tokens for Haiku output
HAIKU_MAX_TOKENS=8192

################################################################################
# Token Estimation Configuration
################################################################################

# Encoding to use for tiktoken (cl100k_base is GPT-4, closest available to Claude)
TIKTOKEN_ENCODING="cl100k_base"

# Fallback: average characters per token (used when tiktoken unavailable)
CHARS_PER_TOKEN_FALLBACK=4

################################################################################
# Summarization Behavior
################################################################################

# Enable/disable automatic summarization
AUTO_SUMMARIZE=true

# Number of retry attempts if Haiku API fails
HAIKU_MAX_RETRIES=3

# Timeout for Haiku API calls (seconds)
HAIKU_TIMEOUT=30

################################################################################
# Information Preservation Levels
################################################################################

# Percentage preservation targets
CRITICAL_PRESERVATION=100  # Must preserve 100%
HIGH_PRESERVATION=100      # Must preserve 100%
MEDIUM_PRESERVATION=80     # Condense to 80%
LOW_PRESERVATION=30        # Summarize to 30%

################################################################################
# File Management
################################################################################

# Directory for original reports (before summarization)
ORIGINAL_REPORTS_DIR="/tmp/claude-work-reports"

# Suffix for summarized files
SUMMARIZED_SUFFIX=".summarized.md"

# Maximum number of original files to keep
MAX_ORIGINAL_FILES=10

################################################################################
# Logging Configuration
################################################################################

# Enable detailed logging
DEBUG_TOKENS=false

# Log file for token operations
TOKEN_LOG_FILE="/tmp/em-team-token.log"

################################################################################
# Helper Functions
################################################################################

# Get effective summarization threshold (can be overridden)
get_threshold() {
    echo "${SUMMARIZATION_THRESHOLD:-150000}"
}

# Get effective token budget (can be overridden)
get_budget() {
    echo "${TOKEN_BUDGET:-200000}"
}

# Check if summarization should be triggered
should_summarize() {
    local token_count=$1
    local threshold=${2:-$SUMMARIZATION_THRESHOLD}

    [[ $token_count -gt $threshold ]]
}

# Calculate target size for summarization
calculate_target_size() {
    local current_size=$1
    local target=${2:-$TARGET_SUMMARY_SIZE}

    # If current size is much larger than target, aim for more aggressive reduction
    if [[ $current_size -gt $((target * 2)) ]]; then
        echo $((target / 2))
    else
        echo "$target"
    fi
}

# Export functions
export -f get_threshold get_budget should_summarize calculate_target_size
