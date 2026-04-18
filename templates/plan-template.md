# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or incremental-implementation to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Spec Reference:** [Link to spec document]

---

## File Structure

```
[Directory structure showing what files will be created/modified]
```

## Tasks

### Task 1: [Component/Feature Name]

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext:123-145`
- Test: `tests/exact/path/to/test.ext`

**Description:** [What this task accomplishes]

- [ ] **Step 1: Write the failing test**

```typescript
// Test code here
describe('Feature', () => {
  it('should do something', () => {
    // Arrange
    const input = {};

    // Act
    const result = function(input);

    // Assert
    expect(result).toBe(expected);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npm test -- --grep "should do something"`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```typescript
// Implementation code here
export function function(input: InputType): OutputType {
  return expected;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npm test -- --grep "should do something"`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add path/to/file.ext path/to/test.ext
git commit -m "feat: add feature description"
```

### Task 2: [Next Component/Feature]

[Continue with remaining tasks...]

---

## Verification

After completing all tasks:

- [ ] All tests pass: `npm test`
- [ ] Type check passes: `npx tsc --noEmit`
- [ ] Lint passes: `npm run lint`
- [ ] Build succeeds: `npm run build`
- [ ] Manual testing completed (if applicable)

## Notes

[Any additional notes, edge cases, or considerations]
