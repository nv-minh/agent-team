# EM-Skill Commands

CLI commands để tăng tốc các workflows thường gặp.

Source: GSD + gstack + superpowers best practices

## Commands Available

### 1. quick.sh ⚡
Execute quick tasks với minimal overhead.

**Usage:**
```bash
em-skill quick <task-description>
```

**Examples:**
```bash
em-skill quick fix typo in README
em-skill quick add error handling to auth
em-skill quick update dependencies
```

**Use for:**
- Small, self-contained tasks
- Quick fixes
- Minor updates

**Not for:**
- Large features (use `new-feature` workflow)
- Complex refactors (use `refactoring` workflow)

---

### 2. debug.sh 🐛
Systematic debugging với root cause investigation.

**Usage:**
```bash
em-skill debug <bug-description>
```

**Examples:**
```bash
em-skill debug "User cannot login after password reset"
em-skill debug "API returns 500 when creating order"
em-skill debug "Memory leak in WebSocket handler"
```

**Process:**
1. INVESTIGATE - Reproduce và collect data
2. ANALYZE - Examine code và patterns
3. HYPOTHESIZE - Form và test hypothesis
4. IMPLEMENT - Fix root cause với regression test

**Iron Law:** NO FIXES WITHOUT ROOT CAUSE

---

### 3. review.sh 👁️
Trigger 5-axis code review.

**Usage:**
```bash
em-skill review [target]
```

**Examples:**
```bash
em-skill review              # Review staged changes
em-skill review main         # Review diff from main
em-skill review abc123       # Review specific commit
em-skill review --file src/auth/login.ts
```

**5 Axes:**
1. Correctness - Code đúng logic?
2. Readability - Code dễ hiểu?
3. Architecture - Tuân thủ kiến trúc?
4. Security - Có lỗ hổng?
5. Performance - Có vấn đề hiệu suất?

---

### 4. qa.sh 🧪
Systematically QA test web application.

**Usage:**
```bash
em-skill qa <url> [scope]
```

**Examples:**
```bash
em-skill qa http://localhost:3000
em-skill qa https://staging.example.com
em-skill qa /dashboard critical
```

**Scopes:**
- `full` - Complete QA test suite (default)
- `critical` - Critical paths only
- `smoke` - Basic functionality
- `visual` - Visual regression only

**Checks:**
- Critical paths (auth, CRUD, etc.)
- Console errors
- Performance
- Responsive design
- Visual consistency
- Accessibility

---

### 5. ship.sh 🚢
Complete ship workflow.

**Usage:**
```bash
em-skill ship
```

**Process:**
1. Check git status
2. Check base branch updates
3. Run tests
4. Run lint
5. Build
6. Bump version
7. Update CHANGELOG
8. Create PR

**Prepares:**
- Version bump
- Changelog updates
- Documentation updates
- PR against base branch

---

### 6. verify.sh ✅
Verify implementation against spec.

**Usage:**
```bash
em-skill verify [spec-file]
```

**Examples:**
```bash
em-skill verify
em-skill verify SPEC.md
em-skill verify docs/auth-spec.md
```

**Verifies:**
1. Objectives met
2. Commands/endpoints implemented
3. Structure follows conventions
4. Code style compliant
5. Testing strategy met
6. Boundaries respected

**Generates:**
- Verification report
- Gap analysis
- Recommendations

---

### 7. health.sh 🏥
Diagnose project health.

**Usage:**
```bash
em-skill health
```

**Checks:**
- Git repository status
- Package manager
- Tests
- Linting
- Build
- Documentation
- Dependencies (vulnerabilities)
- Git hooks installed
- CI/CD configured
- EM-Skill integration

**Output:**
- Health score (0-100)
- Status (Excellent/Good/Fair/Poor)
- Recommendations
- Quick fixes

---

### 8. checkpoint.sh 💾
Save và restore working state.

**Usage:**
```bash
em-skill checkpoint <command> [name]
```

**Commands:**
```bash
em-skill checkpoint save [name]      # Save current state
em-skill checkpoint restore <name>   # Restore state
em-skill checkpoint list             # List all checkpoints
em-skill checkpoint delete <name>    # Delete checkpoint
```

---

## Team Commands (8 commands)

### 9. team-lead.sh 🎯
Orchestrate full team review.

**Usage:**
```bash
em-skill team-lead "[task description]"
```

**Examples:**
```bash
em-skill team-lead "Review new payment feature before implementation"
em-skill team-lead "Architecture review for microservices migration"
em-skill team-lead "Cross-functional review for checkout flow"
```

**Orchestrates:**
- Product Manager (business validation)
- Architect (technical design)
- Frontend Expert (UI/UX)
- Database Expert (data layer)
- Senior Code Reviewer (code quality)
- Security Reviewer (security assessment)
- Staff Engineer (deep investigation)

**Trigger:** `duck:team-lead`

---

### 10. arch-review.sh 🏗️
Architecture review with Architect and Staff Engineer.

**Usage:**
```bash
em-skill arch-review "[architecture description]"
```

**Examples:**
```bash
em-skill arch-review "Review hexagonal architecture for user service"
em-skill arch-review "Assess microservices decomposition strategy"
em-skill arch-review "Review event-driven architecture for payments"
```

**Reviews:**
- Architectural patterns (Layered, Hexagonal, Microservices, Event-Driven)
- Architecture principles
- Technical design
- Cross-service impact
- Scalability

**Trigger:** `duck:architect` + `duck:staff`

---

### 11. design-review.sh 🎨
UI/UX design review with Frontend Expert and Product Manager.

**Usage:**
```bash
em-skill design-review "[design description]"
```

**Examples:**
```bash
em-skill design-review "Review checkout flow UI design"
em-skill design-review "Assess dashboard component design"
em-skill design-review "Review mobile app navigation design"
```

**Reviews:**
- User stories (INVEST criteria)
- User flows
- Component architecture
- Core Web Vitals (LCP, FID, CLS)
- Accessibility (WCAG 2.1 AA/AAA)
- Responsive design

**Trigger:** `duck:product` + `duck:frontend`

---

### 12. code-review-9.sh 🔍
Deep 9-axis code review with Senior Code Reviewer and Security Reviewer.

**Usage:**
```bash
em-skill code-review-9 "[PR or code description]"
```

**Examples:**
```bash
em-skill code-review-9 "Review PR #123 for payment processing"
em-skill code-review-9 "Review authentication module for security"
em-skill code-review-9 "Assess code quality of user service refactoring"
```

**9 Axes:**
1. Correctness ✅
2. Readability 📖
3. Architecture 🏗️
4. Security 🔒
5. Performance ⚡
6. Testing 🧪
7. Maintainability 🔧
8. Scalability 📈
9. Documentation 📚

**Trigger:** `duck:code-review` + `duck:security`

---

### 13. db-review.sh 🗄️
Database review with Database Expert and Architect.

**Usage:**
```bash
em-skill db-review "[database description]"
```

**Examples:**
```bash
em-skill db-review "Review schema for payment ledger system"
em-skill db-review "Assess query performance for reporting dashboard"
em-skill db-review "Review migration strategy for user table split"
```

**Reviews:**
- Schema design (normalization, naming, types)
- Query performance and optimization
- Indexing strategy
- Migration plan
- Data integrity
- Fintech patterns (ledger, audit trail)

**Trigger:** `duck:database` + `duck:architect`

---

### 14. product-review.sh 📦
Product/spec review with Product Manager and Architect.

**Usage:**
```bash
em-skill product-review "[spec or requirement description]"
```

**Examples:**
```bash
em-skill product-review "Review spec for new payment feature"
em-skill product-review "Validate requirements for user onboarding flow"
em-skill product-review "Assess market fit for subscription management"
```

**Reviews:**
- Requirements validation
- GAP analysis
- Acceptance criteria
- User stories (INVEST)
- Business impact and ROI
- Market fit
- Technical feasibility

**Trigger:** `duck:product` + `duck:architect`

---

### 15. security-review.sh 🔒
Advanced security review with Security Reviewer and Staff Engineer.

**Usage:**
```bash
em-skill security-review "[security description]"
```

**Examples:**
```bash
em-skill security-review "Perform OWASP assessment on payment system"
em-skill security-review "STRIDE threat modeling for API gateway"
em-skill security-review "Security review for authentication service"
```

**Assessment:**
- OWASP Top 10 (A01-A10)
- STRIDE threat modeling
- Cross-service security impact
- Dependency security
- Infrastructure security

**BLOCKING Authority:** CRITICAL/HIGH issues must be fixed

**Trigger:** `duck:security` + `duck:staff`

---

### 16. incident.sh 🚨
Production incident response with Staff Engineer and Security Reviewer.

**Usage:**
```bash
em-skill incident "[incident description]"
```

**Examples:**
```bash
em-skill incident "Production outage - API returning 500 errors"
em-skill incident "Database connection pool exhausted"
em-skill incident "Security alert - unusual login patterns"
em-skill incident "Payment processing failures"
```

**Process:**
1. Initial assessment & triage (P0/P1/P2/P3)
2. Security investigation (if applicable)
3. Root cause analysis (5 Whys, fishbone)
4. Cross-service impact analysis
5. Resolution & verification
6. Blameless postmortem

**Trigger:** `duck:staff` + `duck:security`

---

## Command Integration Table

| Command | Uses Agent(s) | Uses Workflow | Purpose |
|---------|---------------|---------------|---------|
| quick | executor | - | Quick tasks |
| debug | debugger | bug-fix | Systematic debugging |
| review | code-reviewer | - | 5-axis code review |
| qa | - | - | QA testing |
| ship | executor | - | Ship workflow |
| verify | verifier | - | Verify implementation |
| health | - | - | Project health |
| checkpoint | - | - | State management |
| **team-lead** | **team-lead + all** | **team-review** | **Full team orchestration** |
| **arch-review** | **architect + staff** | **architecture-review** | **Architecture assessment** |
| **design-review** | **product + frontend** | **design-review** | **UI/UX design review** |
| **code-review-9** | **code-review + security** | **code-review-9axis** | **9-axis deep review** |
| **db-review** | **database + architect** | **database-review** | **Database assessment** |
| **product-review** | **product + architect** | **product-review** | **Product requirements review** |
| **security-review** | **security + staff** | **security-review-advanced** | **Advanced security** |
| **incident** | **staff + security** | **incident-response** | **Incident handling** |

---

## Cài đặt Commands

**All 16 commands (8 core + 8 team) are installed using the same methods.**

### Option 1: Symlink (Recommended)
```bash
# Create bin directory
mkdir -p ~/.local/bin

# Symlink all commands
ln -s $(pwd)/em-skill/commands/*.sh ~/.local/bin/em-skill-*

# Create wrapper script
cat > ~/.local/bin/em-skill << 'EOF'
#!/bin/bash
COMMAND="$1"
shift
~/.local/bin/em-skill-${COMMAND}.sh "$@"
EOF

chmod +x ~/.local/bin/em-skill

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"
```

### Option 2: Alias
```bash
# Add to ~/.bashrc or ~/.zshrc
# Core commands
alias em-skill-quick='bash /path/to/em-skill/commands/quick.sh'
alias em-skill-debug='bash /path/to/em-skill/commands/debug.sh'
alias em-skill-review='bash /path/to/em-skill/commands/review.sh'
alias em-skill-qa='bash /path/to/em-skill/commands/qa.sh'
alias em-skill-ship='bash /path/to/em-skill/commands/ship.sh'
alias em-skill-verify='bash /path/to/em-skill/commands/verify.sh'
alias em-skill-health='bash /path/to/em-skill/commands/health.sh'
alias em-skill-checkpoint='bash /path/to/em-skill/commands/checkpoint.sh'

# Team commands
alias em-skill-team-lead='bash /path/to/em-skill/commands/team-lead.sh'
alias em-skill-arch-review='bash /path/to/em-skill/commands/arch-review.sh'
alias em-skill-design-review='bash /path/to/em-skill/commands/design-review.sh'
alias em-skill-code-review-9='bash /path/to/em-skill/commands/code-review-9.sh'
alias em-skill-db-review='bash /path/to/em-skill/commands/db-review.sh'
alias em-skill-product-review='bash /path/to/em-skill/commands/product-review.sh'
alias em-skill-security-review='bash /path/to/em-skill/commands/security-review.sh'
alias em-skill-incident='bash /path/to/em-skill/commands/incident.sh'
```

---

**EM-Skill Version:** 1.1.0
**Last Updated:** 2026-04-19
**Total Commands:** 16 (8 core + 8 team)
