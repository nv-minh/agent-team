# TDD Auto-Retry Mechanism - Quick Reference

## Overview

The TDD Auto-Retry mechanism automatically captures test failures and feeds them back to the AI for fixing, implementing the RED-GREEN-REFACTOR cycle with intelligent retry logic and exponential backoff.

## Key Features

- ✅ **Automatic Error Capture**: Saves test failures as JSON with full context
- ✅ **Exponential Backoff**: 1s → 2s → 4s delays between retries
- ✅ **Max 3 Retries**: Prevents infinite loops
- ✅ **AI-Friendly Format**: Structured JSON for easy parsing
- ✅ **Persistent Context**: Survives bash session restarts
- ✅ **Exit Code Convention**: 0=success, 42=retry, 43=max exceeded

## File Structure

```
tests/
├── tdd-retry-wrapper.sh          # Core retry logic with exponential backoff
├── tdd-context-manager.sh        # Error capture and JSON formatting
├── test-tdd-retry.sh             # Test suite (10 tests, all passing)
└── test-helpers.sh               # TDD support functions

.claude/tdd-context/
├── test-failure-{timestamp}.json  # Individual failure records
├── test-latest-failure.json       # Latest failure (symlink)
└── test-retry-count.txt           # Current retry counter
```

## Usage

### In Pre-Commit Hook (Automatic)

The pre-commit hook automatically uses the retry wrapper:

```bash
git commit -m "feat: Add new feature"
# Tests run automatically with retry logic
```

### Manual Usage

```bash
# Run tests with retry
./tests/tdd-retry-wrapper.sh run "npm test" 3

# Check retry status
./tests/tdd-context-manager.sh status

# Format latest failure for AI
./tests/tdd-context-manager.sh format

# Reset retry context
./tests/tdd-context-manager.sh reset

# List all failures
./tests/tdd-context-manager.sh list
```

## Exit Codes

- **0**: Success (tests passed)
- **42**: Retry requested (test failed, will retry)
- **43**: Max retries exceeded (manual intervention required)

## Exponential Backoff

```
Retry 1: Wait 1 second
Retry 2: Wait 2 seconds
Retry 3: Wait 4 seconds
Max: 3 retries (then stop)
```

## Error Context Format

```json
{
  "timestamp": "2026-04-19T13:00:00Z",
  "retry_count": 1,
  "max_retries": 3,
  "exit_code": 1,
  "test_command": "npm run test:unit -- --passWithNoTests",
  "output": "Full test output with colors...",
  "working_directory": "/Users/abc/Desktop/EM-Skill",
  "git_branch": "feature/tdd-auto-retry",
  "git_commit": "abc123def456"
}
```

## AI Feedback Loop

```
1. Test Fails (RED)
   ↓ Wrapper captures error
   ↓ Saves to .claude/tdd-context/
   ↓ Returns exit code 42

2. AI Receives Context
   ↓ Reads JSON file
   ↓ Analyzes error output
   ↓ Identifies root cause

3. AI Generates Fix
   ↓ Writes production code (GREEN)
   ↓ Follows TDD Iron Law
   ↓ Makes minimal changes

4. Automatic Re-test
   ↓ AI runs test command
   ↓ Wrapper checks result
   ↓ Pass: Reset counter, return 0
   ↓ Fail: Increment counter, return 42

5. Success or Continue
   ↓ Pass: GREEN phase complete
   ↓ Fail: Check if retries remain
   ↓ Max retries: Return 43, stop
```

## Test Results

All 10 tests passing:

```
✓ Success resets retry counter
✓ Failure creates error context
✓ Retry counter increments correctly
✓ Exit code 42 when retry available
✓ Exit code 43 when max retries exceeded
✓ Context manager formats failure
✓ Context manager shows status
✓ Context manager resets context
✓ Exponential backoff delays
✓ Max retries configuration
```

## Integration Points

### Pre-Commit Hook

Modified `hooks/pre-commit` (lines 75-96) to:
- Source TDD retry wrapper
- Run tests with retry logic
- Interpret exit codes (42, 43)
- Display helpful error messages

### Test Helpers

Added to `tests/test-helpers.sh`:
- `run_test_with_retry()` - Execute test with wrapper
- `has_retry_context()` - Check for existing context
- `get_retry_count()` - Get current retry number
- `format_tdd_failure()` - Display TDD RED phase message
- `log_tdd_phase()` - Log phase transitions
- `reset_tdd_context()` - Clear retry counter
- `show_tdd_status()` - Display current status

### TDD Documentation

Updated `skills/development/test-driven-development/test-driven-development.md` with:
- How auto-retry system works
- Usage instructions
- Error context format
- AI agent integration points
- Troubleshooting guide

## Benefits

1. **No Manual Copy-Paste**: Error context automatically captured
2. **Reduced Noise**: Exponential backoff handles flaky tests
3. **AI-Friendly**: Structured JSON for easy parsing
4. **Persistent**: Survives bash session restarts
5. **Clear Feedback**: Color-coded status messages
6. **Maintains TDD Iron Law**: RED-GREEN-REFACTOR automated

## Troubleshooting

### Problem: Tests keep failing with same error

```bash
# Check the error details
./tests/tdd-context-manager.sh format

# Reset retry counter to start fresh
./tests/tdd-context-manager.sh reset
```

### Problem: Max retries exceeded

```bash
# View all failure files
./tests/tdd-context-manager.sh list

# Manual intervention required
# Fix the issue manually, then reset
./tests/tdd-context-manager.sh reset
```

### Problem: Stale error context

```bash
# Clean up old failure files
./tests/tdd-context-manager.sh cleanup
```

## Next Steps

The auto-retry TDD feature is now **fully implemented and tested**. Phase 1 is complete!

**Remaining Work (from implementation plan):**
- Phase 2: Token Summarization (Priority 2)
  - Create token-counter.sh
  - Create haiku-client.sh
  - Modify consolidate-reports.sh
  - Update report-format.md

## Verification

To verify the auto-retry mechanism is working:

```bash
# Run test suite
./tests/test-tdd-retry.sh

# Expected: All 10 tests pass

# Check files exist
ls -la tests/tdd-retry-wrapper.sh
ls -la tests/tdd-context-manager.sh
ls -la tests/test-tdd-retry.sh

# Check pre-commit hook integration
grep -A 5 "TDD Auto-Retry" hooks/pre-commit
```

## Status

✅ **Auto-Retry TDD Implementation Complete**

- All core components implemented
- Pre-commit hook integrated
- Test helpers updated
- Documentation updated
- All tests passing (10/10)
- Ready for production use

---

**Implementation Date**: 2026-04-19
**Phase**: Week 1, Day 1-2 (Foundation)
**Status**: ✅ Complete
