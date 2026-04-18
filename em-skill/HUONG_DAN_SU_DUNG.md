# Hướng Dẫn Sử Dụng EM-Skill

Tài liệu này hướng dẫn chi tiết cách sử dụng hệ thống EM-Skill bao gồm Agents, Workflows và Skills.

---

## 📋 Mục Lục

1. [Tổng Quan](#tổng-quan)
2. [Cách Sử Dụng Agents](#cách-sử-dụng-agents)
3. [Cách Sử Dụng Workflows](#cách-sử-dụng-workflows)
4. [Cách Sử Dụng Skills](#cách-sử-dụng-skills)
5. [Ví Dụ Thực Tế](#ví-dụ-thực-tế)

---

## Tổng Quan

EM-Skill là hệ thống fullstack engineering với 3 thành phần chính:

| Thành phần | Số lượng | Mục đích |
|-----------|---------|---------|
| **Skills** | 25 | Kỹ năng có thể tái sử dụng |
| **Agents** | 8 | Chuyên gia xử lý tác vụ cụ thể |
| **Workflows** | 8 | Quy trình end-to-end |

---

## Cách Sử Dụng Agents

### Agent 1: Planner (Người lập kế hoạch)

**Mục đích:** Tạo kế hoạch triển khai chi tiết từ requirements.

**Cách sử dụng:**
```
"Agent: planner - Hãy tạo kế hoạch triển khai cho tính năng xác thực người dùng"
```

**Đầu vào:**
- Yêu cầu tính năng (feature requirement)
- Specs (nếu có)
- Context về dự án

**Đầu ra:**
- Kế hoạch chi tiết với task breakdown
- Thứ tự thực hiện
- Tiêu chí chấp nhận (acceptance criteria)
- Ước tính thời gian

**Ví dụ thực tế:**
```
User: "Agent: planner - Tôi muốn thêm tính năng đăng nhập bằng Google OAuth"

Planner sẽ tạo kế hoạch:
1. Thiết lập Google Cloud Console project
2. Cấu hình OAuth credentials
3. Cài đặt dependencies (google-auth-library)
4. Tạo OAuth callback endpoint
5. Lưu user info vào database
6. Tạo JWT session
7. Viết tests cho từng bước
```

---

### Agent 2: Executor (Người thực thi)

**Mục đích:** Thực thi kế hoạch với atomic commits.

**Cách sử dụng:**
```
"Agent: executor - Thực thi task #1 từ kế hoạch: thiết lập Google Cloud Console"
```

**Đầu vào:**
- Kế hoạch đã được phê duyệt
- Task cần thực hiện
- Source code hiện tại

**Đầu ra:**
- Code được implement
- Atomic commit (mỗi commit = 1 logical unit)
- Tests passing
- Quality gates được đảm bảo

**Ví dụ thực tế:**
```
User: "Agent: executor - Implement OAuth callback endpoint"

Executor sẽ:
1. Đọc spec và plan
2. Viết code cho callback endpoint
3. Viết tests (TDD: RED → GREEN → REFACTOR)
4. Run tests
5. Tạo atomic commit: "feat: add OAuth callback endpoint"
6. Xác nhận quality gates
```

---

### Agent 3: Code-Reviewer (Người review code)

**Mục đích:** Review code theo 5 trục: Correctness, Readability, Architecture, Security, Performance.

**Cách sử dụng:**
```
"Agent: code-reviewer - Review các thay đổi trong PR #42"
```

**Đầu vào:**
- Pull request hoặc code changes
- Base branch để so sánh
- Context về project

**Đầu ra:**
- Review theo 5 trục
- Specific feedback với line numbers
- Actionable suggestions
- Approval hoặc request changes

**Ví dụ thực tế:**
```
User: "Agent: code-reviewer - Review commit abc123 về OAuth login"

Code-Reviewer sẽ phân tích:
✅ Correctness: Code có đúng logic không?
✅ Readability: Code có dễ hiểu không?
✅ Architecture: Có tuân thủ kiến trúc project không?
✅ Security: Có lỗ hổng bảo mật không?
✅ Performance: Có vấn đề hiệu suất không?

Và đưa ra feedback cụ thể:
- Line 15: Sử dụng async/await thay vì Promise chain
- Line 23: Thêm error handling cho network failures
- Line 45: Validate state parameter để prevent CSRF
```

---

### Agent 4: Debugger (Người debug)

**Mục đích:** Debug có hệ thống theo scientific method.

**Cách sử dụng:**
```
"Agent: debugger - Điều tra bug: user không thể đăng nhập sau khi reset password"
```

**Đầu vào:**
- Bug report hoặc error
- Reproduction steps
- Logs và stack traces

**Đầu ra:**
- Root cause analysis
- Hypothesis đã được test
- Fix với tests
- Documentation về bug

**Ví dụ thực tế:**
```
User: "Agent: debugger - Error 500 khi tạo user mới"

Debugger sẽ:
Phase 1 - INVESTIGATE:
  - Reproduce bug
  - Collect logs
  - Xác định scope

Phase 2 - ANALYZE:
  - Analyze stack trace
  - Xem code paths
  - Identify data flow

Phase 3 - HYPOTHESIZE:
  - "Lỗi do database constraint violation"
  - Test hypothesis với unit test

Phase 4 - IMPLEMENT:
  - Fix root cause
  - Add regression test
  - Verify fix works
```

---

### Agent 5: Test-Engineer (Kỹ sư kiểm thử)

**Mục đích:** Tạo test strategy và generate tests.

**Cách sử dụng:**
```
"Agent: test-engineer - Tạo test suite cho OAuth login flow"
```

**Đầu vào:**
- Feature spec hoặc code
- Requirements
- Existing tests

**Đầu ra:**
- Test strategy document
- Test cases (unit, integration, E2E)
- Test code
- Coverage report

**Ví dụ thực tế:**
```
User: "Agent: test-engineer - Viết tests cho API endpoint POST /api/users"

Test-Engineer sẽ tạo:

Unit Tests (80%):
- Test validation: invalid email, missing fields
- Test success: valid user creation
- Test duplicates: email already exists
- Test edge cases: max length, special characters

Integration Tests (15%):
- Test database integration
- Test with real dependencies

E2E Tests (5%):
- Test complete flow từ request đến response

Coverage target: >80%
```

---

### Agent 6: Security-Auditor (Kiểm toán bảo mật)

**Mục đích:** Audit bảo mật theo OWASP Top 10.

**Cách sử dụng:**
```
"Agent: security-auditor - Audit authentication module"
```

**Đầu vào:**
- Code hoặc module
- Requirements
- Architecture docs

**Đầu ra:**
- Vulnerability report
- Risk ratings (Critical/High/Medium/Low)
- Remediation steps
- Security best practices

**Ví dụ thực tế:**
```
User: "Agent: security-auditor - Kiểm tra login form"

Security-Auditor sẽ kiểm tra:

OWASP Top 10:
❌ A01: Broken Access Control → Check authorization
❌ A02: Cryptographic Failures → Check password hashing
❌ A03: Injection → Check SQL injection vulnerabilities
❌ A07: Authentication Failures → Check brute force protection
✓ A08: Software and Data Integrity → Check dependencies
...

Report:
- CRITICAL: Password stored in plaintext (A02)
- HIGH: No rate limiting on login (A07)
- MEDIUM: SQL injection in search (A03)
```

---

### Agent 7: UI-Auditor (Kiểm toán UI)

**Mục đích:** Visual QA và 6-pillar UI audit.

**Cách sử dụng:**
```
"Agent: ui-auditor - Audit dashboard page"
```

**Đầu vào:**
- UI screenshots hoặc URL
- Design specs
- User stories

**Đầu ra:**
- Visual consistency report
- Responsive design check
- Accessibility audit
- UX recommendations

**Ví dụ thực tế:**
```
User: "Agent: ui-auditor - Review trang profile user"

UI-Auditor sẽ kiểm tra:

6 Pillars:
1. Visual Consistency:
   - Fonts, colors, spacing consistent?
   - Design system followed?

2. Responsive Design:
   - Mobile, tablet, desktop layouts?
   - Breakpoints correct?

3. Accessibility:
   - ARIA labels present?
   - Keyboard navigation works?
   - Color contrast sufficient?

4. Performance:
   - Load time acceptable?
   - Images optimized?

5. User Experience:
   - Intuitive navigation?
   - Clear CTAs?

6. Browser Compatibility:
   - Chrome, Firefox, Safari tested?
```

---

### Agent 8: Verifier (Người xác minh)

**Mục đích:** Xác minh sau khi thực thi against spec và requirements.

**Cách sử dụng:**
```
"Agent: verifier - Xác minh tính năng authentication đã hoàn thành"
```

**Đầu vào:**
- Implementation đã hoàn thành
- Original spec
- Requirements
- Test results

**Đầu ra:**
- Verification report
- Gaps identified
- Recommendations
- Approval/rejection

**Ví dụ thực tế:**
```
User: "Agent: verifier - Verify OAuth login feature"

Verifier sẽ kiểm tra:

Against Spec:
✓ Objective: Users can login with Google - IMPLEMENTED
✓ Commands: /login/google endpoint - WORKING
✓ Project Structure: Follows conventions - YES
✓ Code Style: TypeScript strict mode - PASS
✓ Testing Strategy: Unit + Integration tests - 85% coverage
✓ Boundaries: No scope creep - CONFIRMED

Against Requirements:
✓ Functional: Login works - PASS
✓ Non-functional: Performance < 200ms - PASS
✓ Security: CSRF protection - PASS

Result: ✅ APPROVED - Ready to merge
```

---

## Cách Sử Dụng Workflows

### Workflow 1: New-Feature (Tính năng mới)

**Mục đích:** Đưa tính năng từ ý tưởng đến production.

**Quy trình:**
```
BRAINSTORM → SPEC → PLAN → BUILD → VERIFY → SHIP
```

**Cách sử dụng:**
```
"Workflow: new-feature - Thêm tính năng đăng nhập bằng Google"
```

**Chi tiết từng phase:**

#### Phase 1: BRAINSTORM
```
"Use brainstorming skill to explore Google OAuth implementation"

→ Output: Design decisions, tech choices, potential issues
```

#### Phase 2: SPEC
```
"Use spec-driven-development skill to create spec"

→ Output: SPEC.md với:
  - Objective
  - Commands (API endpoints)
  - Project Structure
  - Code Style
  - Testing Strategy
  - Boundaries
```

#### Phase 3: PLAN
```
"Agent: planner - Create implementation plan from spec"

→ Output: PLAN.md với:
  - Task breakdown
  - Dependencies
  - Acceptance criteria
  - Timeline
```

#### Phase 4: BUILD
```
"Agent: executor - Implement tasks from plan"

→ Output:
  - Code với TDD (RED → GREEN → REFACTOR)
  - Atomic commits
  - Tests passing
```

#### Phase 5: VERIFY
```
"Agent: code-reviewer - Review implementation"
"Agent: test-engineer - Verify test coverage"
"Agent: security-auditor - Security audit"

→ Output:
  - Review reports
  - Test coverage > 80%
  - Security approved
```

#### Phase 6: SHIP
```
"Use git-workflow skill to create PR and merge"

→ Output:
  - PR created
  - CI/CD passing
  - Merged to main
  - Deployed to production
```

---

### Workflow 2: Bug-Fix (Sửa lỗi)

**Mục đích:** Sửa lỗi có hệ thống.

**Quy trình:**
```
INVESTIGATE → ANALYZE → HYPOTHESIZE → FIX → VERIFY
```

**Cách sử dụng:**
```
"Workflow: bug-fix - Sửa lỗi: user không thể đăng nhập sau reset password"
```

**Chi tiết từng phase:**

#### Phase 1: INVESTIGATE
```
"Agent: debugger - Investigate the bug"

→ Output:
  - Reproduction steps
  - Scope of issue
  - Related code
  - Logs collected
```

#### Phase 2: ANALYZE
```
"Agent: debugger - Analyze root cause"

→ Output:
  - Stack trace analysis
  - Data flow analysis
  - Code path analysis
```

#### Phase 3: HYPOTHESIZE
```
"Agent: debugger - Create and test hypothesis"

→ Output:
  - Hypothesis documented
  - Test to verify
  - Root cause confirmed
```

#### Phase 4: FIX
```
"Agent: executor - Implement fix"

→ Output:
  - Fix implemented
  - Regression test added
  - Atomic commit
```

#### Phase 5: VERIFY
```
"Agent: verifier - Verify fix"

→ Output:
  - Fix verified
  - No regressions
  - Bug closed
```

---

### Workflow 3: Refactoring (Cải tiến code)

**Mục đích:** Cải thiện chất lượng code.

**Quy trình:**
```
ANALYZE → PLAN → REFACTOR → VERIFY → UPDATE
```

**Cách sử dụng:**
```
"Workflow: refactoring - Refactor authentication module"
```

**Chi tiết từng phase:**

#### Phase 1: ANALYZE
```
"Agent: code-reviewer - Analyze current code"

→ Output:
  - Complexity issues
  - Code smells
  - Improvement opportunities
```

#### Phase 2: PLAN
```
"Agent: planner - Create refactoring plan"

→ Output:
  - Refactoring tasks
  - Order of changes
  - Risk mitigation
```

#### Phase 3: REFACTOR
```
"Agent: executor - Execute refactoring"

→ Output:
  - Refactored code
  - Tests still passing
  - Atomic commits
```

#### Phase 4: VERIFY
```
"Agent: code-reviewer - Review refactored code"
"Agent: test-engineer - Verify no regressions"

→ Output:
  - Code quality improved
  - Tests passing
  - Performance maintained
```

#### Phase 5: UPDATE
```
"Use documentation skill to update docs"

→ Output:
  - Documentation updated
  - ADR created (if needed)
```

---

### Workflow 4: Security-Audit (Kiểm toán bảo mật)

**Mục đích:** Audit bảo mật toàn diện.

**Quy trình:**
```
SCAN → ANALYZE → REMEDIATE → VERIFY → DOCUMENT
```

**Cách sử dụng:**
```
"Workflow: security-audit - Audit toàn bộ authentication system"
```

**Chi tiết từng phase:**

#### Phase 1: SCAN
```
"Agent: security-auditor - Scan for vulnerabilities"

→ Output:
  - Automated scan results
  - Dependency vulnerabilities
  - Code patterns flagged
```

#### Phase 2: ANALYZE
```
"Agent: security-auditor - Analyze findings"

→ Output:
  - Risk assessment
  - Prioritized issues
  - Impact analysis
```

#### Phase 3: REMEDIATE
```
"Agent: executor - Fix security issues"

→ Output:
  - Vulnerabilities fixed
  - Security tests added
  - Atomic commits
```

#### Phase 4: VERIFY
```
"Agent: security-auditor - Verify fixes"

→ Output:
  - All issues resolved
  - Rescan clean
```

#### Phase 5: DOCUMENT
```
"Use documentation skill to document security"

→ Output:
  - Security report
  - Best practices documented
```

---

### Workflow 5: Project-Setup (Khởi tạo dự án)

**Mục đích:** Khởi tạo dự án mới với best practices.

**Quy trình:**
```
CHOOSE → SCAFFOLD → CONFIGURE → TEST → INITIALIZE
```

**Cách sử dụng:**
```
"Workflow: project-setup - Khởi tạo dự án e-commerce fullstack"
```

**Chi tiết từng phase:**

#### Phase 1: CHOOSE
```
"Use brainstorming skill to choose tech stack"

→ Output:
  - Frontend: React + TypeScript + Vite
  - Backend: Node.js + Express + TypeScript
  - Database: PostgreSQL + Prisma
  - Testing: Jest + Playwright
```

#### Phase 2: SCAFFOLD
```
"Agent: executor - Scaffold project structure"

→ Output:
  - Project structure created
  - Git initialized
  - package.json configured
```

#### Phase 3: CONFIGURE
```
"Agent: executor - Configure tooling"

→ Output:
  - TypeScript strict mode
  - ESLint + Prettier
  - Husky git hooks
  - Jest configured
  - CI/CD pipeline
```

#### Phase 4: TEST
```
"Agent: test-engineer - Verify tooling works"

→ Output:
  - Build successful
  - Tests running
  - CI/CD working
```

#### Phase 5: INITIALIZE
```
"Use git-workflow skill to initialize repo"

→ Output:
  - Initial commit
  - Repository pushed
  - Branches created
  - Team invited
```

---

### Workflow 6: Documentation (Tài liệu hóa)

**Mục đích:** Tạo và cập nhật tài liệu.

**Quy trình:**
```
ANALYZE → GENERATE → REVIEW → UPDATE → PUBLISH
```

**Cách sử dụng:**
```
"Workflow: documentation - Tạo API docs cho authentication endpoints"
```

**Chi tiết từng phase:**

#### Phase 1: ANALYZE
```
"Analyze code and extract API information"

→ Output:
  - Endpoints identified
  - Parameters documented
  - Response formats
```

#### Phase 2: GENERATE
```
"Agent: executor - Generate documentation"

→ Output:
  - API reference created
  - Examples written
  - Diagrams created
```

#### Phase 3: REVIEW
```
"Review documentation for accuracy"

→ Output:
  - Technical review
  - Examples tested
  - Clarity check
```

#### Phase 4: UPDATE
```
"Fix issues and improve clarity"

→ Output:
  - Issues resolved
  - Examples working
```

#### Phase 5: PUBLISH
```
"Use git-workflow skill to publish docs"

→ Output:
  - Docs deployed
  - Team notified
```

---

### Workflow 7: Deployment (Triển khai)

**Mục đích:** Deploy an toàn với monitoring và rollback.

**Quy trình:**
```
PREP → DEPLOY → TEST → MONITOR → FINALIZE
```

**Cách sử dụng:**
```
"Workflow: deployment - Deploy authentication feature to production"
```

**Chi tiết từng phase:**

#### Phase 1: PREP
```
"Agent: executor - Prepare for deployment"

→ Output:
  - All tests passing
  - Build successful
  - Tag created
  - Backup complete
```

#### Phase 2: DEPLOY
```
"Agent: executor - Deploy to staging first"

→ Output:
  - Staging tests pass
  - Smoke tests pass
  - Ready for production
```

#### Phase 3: TEST
```
"Run smoke tests on production"

→ Output:
  - Critical paths work
  - Error rates acceptable
  - Performance OK
```

#### Phase 4: MONITOR
```
"Monitor metrics for 1-2 hours"

→ Output:
  - Response times normal
  - Error rates low
  - No critical errors
```

#### Phase 5: FINALIZE
```
"Finalize deployment"

→ Output:
  - Documentation updated
  - Team notified
  - Deployment recorded
```

---

### Workflow 8: Retro (Hậu nghiệm)

**Mục đích:** Học từ completed work và cải tiến.

**Quy trình:**
```
COLLECT → ANALYZE → IDENTIFY → PLAN → EXECUTE
```

**Cách sử dụng:**
```
"Workflow: retro - Retro sau khi hoàn thành sprint 4"
```

**Chi tiết từng phase:**

#### Phase 1: COLLECT
```
"Collect metrics and feedback"

→ Output:
  - Commit metrics
  - Quality metrics
  - Team feedback
```

#### Phase 2: ANALYZE
```
"Agent: code-reviewer - Analyze patterns"

→ Output:
  - Success patterns identified
  - Issues identified
  - Trends analyzed
```

#### Phase 3: IDENTIFY
```
"Identify improvements"

→ Output:
  - Successes documented
  - Issues prioritized
  - Improvements planned
```

#### Phase 4: PLAN
```
"Agent: planner - Create improvement plan"

→ Output:
  - Action items defined
  - Owners assigned
  - Timeline set
```

#### Phase 5: EXECUTE
```
"Execute improvements"

→ Output:
  - Processes updated
  - Team trained
  - Progress tracked
```

---

## Cách Sử Dụng Skills

### Foundation Skills (Skills nền tảng)

#### Skill 1: Spec-Driven Development

**Mục đích:** Viết spec trước khi code.

**Cách sử dụng:**
```
"Use spec-driven-development skill to create spec for user authentication"
```

**Output:**
- SPEC.md với đầy đủ sections
- Objective rõ ràng
- Commands (API endpoints, CLI commands)
- Project structure
- Code style guidelines
- Testing strategy
- Boundaries (scope)

**Ví dụ:**
```
User: "Use spec-driven-development skill cho tính năng forgot password"

Skill sẽ tạo:
SPEC.md:
  Objective: Allow users to reset password via email

  Commands:
    - POST /api/auth/forgot-password
    - POST /api/auth/reset-password

  Project Structure:
    src/
      auth/
        forgot-password.ts
        reset-password.ts
        email-service.ts

  Testing Strategy:
    - Unit: Email service, token generation
    - Integration: API endpoints
    - E2E: Complete flow

  Boundaries:
    - Out of scope: SMS reset, security questions
```

---

#### Skill 2: Brainstorming

**Mục đích:** Khám phá ý tưởng thành thiết kế.

**Cách sử dụng:**
```
"Use brainstorming skill to explore real-time chat feature design"
```

**Output:**
- Design options explored
- Trade-offs analyzed
- Tech choices evaluated
- Potential issues identified

**Ví dụ:**
```
User: "Use brainstorming skill để thiết kế real-time chat"

Skill sẽ thảo luận:
1. Architecture options:
   - WebSocket vs Server-Sent Events vs Polling
   - Trade-offs: Real-time vs scalability

2. Data model:
   - Messages, conversations, participants
   - Storing message history

3. Tech choices:
   - Socket.io vs native WebSocket
   - Redis for pub/sub

4. Potential issues:
   - Scaling to thousands of concurrent users
   - Message ordering
   - Offline handling
```

---

#### Skill 3: Context-Engineering

**Mục đích:** Cung cấp context đúng lúc cho agent.

**Cách sử dụng:**
```
"Use context-engineering skill to setup context for OAuth implementation"
```

**5-Level Context Hierarchy:**
1. **Rules Files**: CLAUDE.md, .cursorrules
2. **Specs**: Feature specs, requirements
3. **Source Files**: Relevant code files
4. **Error Output**: Stack traces, logs
5. **Conversation History**: Previous context

**Ví dụ:**
```
User: "Use context-engineering skill để setup context cho bug fix"

Skill sẽ hướng dẫn:
Level 1: Rules
  → Read CLAUDE.md for project conventions

Level 2: Specs
  → Read authentication spec

Level 3: Source Files
  → Read login.ts, auth-service.ts

Level 4: Error Output
  → Read stack trace from logs

Level 5: Conversation
  → Review previous debugging attempts
```

---

#### Skill 4: Writing-Plans

**Mục đích:** Chia nhỏ work thành bite-sized tasks.

**Cách sử dụng:**
```
"Use writing-plans skill to break down OAuth implementation"
```

**Output:**
- Task breakdown
- Dependencies mapped
- Acceptance criteria
- Time estimates

**Ví dụ:**
```
User: "Use writing-plans skill để breakdown email verification"

Skill sẽ tạo:

Tasks:
1. Setup email service (SendGrid/Mailgun)
   - Create email-service.ts
   - Configure templates
   - Test email sending

2. Generate verification tokens
   - Create token generation logic
   - Store in database
   - Set expiration (24h)

3. Create verification endpoint
   - POST /api/auth/verify-email
   - Validate token
   - Update user status

4. Add verification to registration flow
   - Send email after registration
   - Block login until verified

5. UI: Show verification prompt
   - Create verification page
   - Add resend email option
```

---

#### Skill 5: Systematic-Debugging

**Mục đích:** Debug có hệ thống.

**Cách sử dụng:**
```
"Use systematic-debugging skill to investigate login failure"
```

**4-Phase Process:**

**Phase 1: INVESTIGATE**
- Reproduce bug
- Collect logs
- Identify scope

**Phase 2: ANALYZE**
- Analyze stack trace
- Examine code paths
- Trace data flow

**Phase 3: HYPOTHESIZE**
- Form hypothesis
- Design test
- Verify hypothesis

**Phase 4: IMPLEMENT**
- Fix root cause
- Add regression test
- Verify fix

**Iron Law: NO FIXES WITHOUT ROOT CAUSE**

**Ví dụ:**
```
User: "Use systematic-debugging skill cho bug: user logged in but redirected to login page"

Phase 1 - INVESTIGATE:
  → Reproduce: Login works, but redirected back
  → Logs: Session cookie not set
  → Scope: Authentication flow

Phase 2 - ANALYZE:
  → Stack trace: No error
  → Code: Cookie set in response
  → Data flow: Token → Cookie → Redirect

Phase 3 - HYPOTHESIZE:
  → "Cookie domain mismatch causes cookie to be rejected"
  → Test: Set cookie with correct domain

Phase 4 - IMPLEMENT:
  → Fix: Use correct domain for cookie
  → Test: Verify cookie is set
  → Commit: "fix: set correct cookie domain"
```

---

### Development Skills (Skills phát triển)

#### Skill 6: Test-Driven Development (TDD)

**Mục đích:** Development theo TDD.

**Cách sử dụng:**
```
"Use test-driven-development skill to implement user registration"
```

**TDD Cycle: RED → GREEN → REFACTOR**

**Iron Law: NO PRODUCTION CODE WITHOUT FAILING TEST**

**Ví dụ:**
```
User: "Use TDD skill để implement password validation"

RED - Write failing test:
  test("password must be at least 8 characters", () => {
    expect(validatePassword("abc")).toBe(false);
  });

  → Run test: FAIL ✗

GREEN - Write minimal code to pass:
  function validatePassword(password: string): boolean {
    return password.length >= 8;
  }

  → Run test: PASS ✓

REFACTOR - Improve code:
  function validatePassword(password: string): boolean {
    const MIN_LENGTH = 8;
    return password.length >= MIN_LENGTH;
  }

  → Run test: PASS ✓

Continue with more tests:
  - Must contain uppercase
  - Must contain number
  - Must contain special char
```

---

#### Skill 7: Frontend-Patterns

**Mục đích:** React/Next.js/Vue patterns.

**Cách sử dụng:**
```
"Use frontend-patterns skill to build user profile component"
```

**Patterns Covered:**
- Component composition
- State management (Context, Zustand, Redux)
- Data fetching (React Query, SWR)
- Performance (memo, lazy loading)
- Forms (React Hook Form, Zod)

**Ví dụ:**
```
User: "Use frontend-patterns skill để tạo product list component"

Skill sẽ hướng dẫn:

1. Component Structure:
   - ProductList.tsx (container)
   - ProductCard.tsx (presentational)
   - useProducts.ts (custom hook)

2. State Management:
   - Server state: React Query
   - Client state: Zustand for filters

3. Data Fetching:
   const { data, isLoading, error } = useProducts();

4. Performance:
   - Virtual scrolling for large lists
   - Image lazy loading
   - Memo for expensive computations

5. Form Handling:
   - Filter form with React Hook Form + Zod
```

---

#### Skill 8: Backend-Patterns

**Mục đích:** API/Database patterns.

**Cách sử dụng:**
```
"Use backend-patterns skill to build order management API"
```

**Patterns Covered:**
- RESTful API design
- Repository pattern
- Service layer
- Transactions
- Authentication/Authorization
- Rate limiting

**Ví dụ:**
```
User: "Use backend-patterns skill để tạo user API"

Skill sẽ hướng dẫn:

1. Repository Pattern:
   class UserRepository {
     async findById(id: string): Promise<User> { }
     async create(data: CreateUserDTO): Promise<User> { }
     async update(id: string, data: UpdateUserDTO): Promise<User> { }
     async delete(id: string): Promise<void> { }
   }

2. Service Layer:
   class UserService {
     constructor(private repo: UserRepository) { }
     async register(data: RegisterDTO): Promise<User> {
       // Business logic
     }
   }

3. Controller:
   router.post("/users", async (req, res) => {
     const user = await userService.register(req.body);
     res.json(user);
   });

4. Authentication:
   - JWT tokens
   - Middleware: requireAuth

5. Rate Limiting:
   - 100 requests per 15 minutes
```

---

#### Skill 9: Incremental-Implementation

**Mục đích:** Vertical slice development.

**Cách sử dụng:**
```
"Use incremental-implementation skill to build e-commerce checkout"
```

**Vertical Slice:**
Build complete, working features end-to-end.

**Ví dụ:**
```
User: "Use incremental-implementation skill cho shopping cart"

Slice 1 - Basic cart:
  - Add item to cart
  - View cart
  - Remove item
  → Complete working feature

Slice 2 - Quantity:
  - Update quantity
  - Validate stock
  → Complete working feature

Slice 3 - Persistence:
  - Save cart to database
  - Restore cart on login
  → Complete working feature

Slice 4 - Calculations:
  - Subtotal
  - Tax
  - Shipping
  → Complete working feature

Each slice is shippable!
```

---

#### Skill 10: Subagent-Driven Development

**Mục đích:** Fresh subagent per task.

**Cách sử dụng:**
```
"Use subagent-driven-development skill to refactor auth module"
```

**Benefits:**
- Clean context window
- Fresh perspective
- Reduced context pollution

**Ví dụ:**
```
User: "Use subagent-driven-development skill cho multi-feature update"

Main agent delegates to subagents:

Subagent 1: "Refactor login.ts"
  → Reads only login.ts and related files
  → Returns refactored code

Subagent 2: "Refactor register.ts"
  → Reads only register.ts and related files
  → Returns refactored code

Subagent 3: "Refactor password-reset.ts"
  → Reads only password-reset.ts and related files
  → Returns refactored code

Main agent: Review and integrate all changes
```

---

#### Skill 11: Source-Driven Development

**Mục đích:** Code từ official docs.

**Cách sử dụng:**
```
"Use source-driven-development skill to integrate Stripe payments"
```

**Process:**
1. Find official documentation
2. Read official examples
3. Adapt to project
4. Link to sources

**Ví dụ:**
```
User: "Use source-driven-development skill cho Next.js 13 app router"

Skill sẽ:
1. Fetch official Next.js docs:
   → https://nextjs.org/docs/app

2. Read official examples:
   → app/layout.tsx structure
   → app/page.tsx patterns

3. Adapt to project:
   → Create app directory
   → Setup layout.tsx
   → Migrate pages

4. Link to sources:
   → Based on: https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts
```

---

#### Skill 12: API-Interface-Design

**Mục đích:** Contract-first API design.

**Cách sử dụng:**
```
"Use api-interface-design skill to design user management API"
```

**Process:**
1. Define types/interfaces
2. Specify validation
3. Document endpoints
4. Generate OpenAPI spec

**Ví dụ:**
```
User: "Use api-interface-design skill cho blog posts API"

Skill sẽ tạo:

1. Types:
   interface CreatePostDTO {
     title: string;
     content: string;
     authorId: string;
     published: boolean;
   }

2. Validation:
   const createPostSchema = z.object({
     title: z.string().min(1).max(200),
     content: z.string().min(1),
     authorId: z.string().uuid(),
     published: z.boolean().default(false),
   });

3. Endpoints:
   POST   /api/posts      - Create post
   GET    /api/posts      - List posts
   GET    /api/posts/:id  - Get post
   PUT    /api/posts/:id  - Update post
   DELETE /api/posts/:id  - Delete post

4. OpenAPI spec generated
```

---

#### Skill 13: Security-Hardening

**Mục đích:** OWASP Top 10 security.

**Cách sử dụng:**
```
"Use security-hardening skill to secure authentication system"
```

**OWASP Top 10 Coverage:**

**A01: Broken Access Control**
- Check authorization on every request
- Use principle of least privilege

**A02: Cryptographic Failures**
- Hash passwords with bcrypt/argon2
- Use TLS everywhere
- Never store secrets in plaintext

**A03: Injection**
- Use parameterized queries
- Validate and sanitize input
- Use ORM

**A07: Authentication Failures**
- Implement rate limiting
- Use strong password policies
- Implement MFA

**Ví dụ:**
```
User: "Use security-hardening skill cho login endpoint"

Skill sẽ kiểm tra:

✓ A01: Access Control
  → Check: Only account owner can login

✓ A02: Cryptography
  → Check: Password hashed with bcrypt
  → Check: JWT tokens signed with secret key

✓ A03: Injection
  → Check: Parameterized query for user lookup

✓ A07: Authentication
  → Check: Rate limiting (5 attempts per minute)
  → Check: Account lockout after 10 failed attempts
```

---

### Quality Skills (Skills chất lượng)

#### Skill 14: Code-Review

**Mục đích:** 5-axis code review.

**Cách sử dụng:**
```
"Use code-review skill to review PR #123"
```

**5 Axes:**
1. **Correctness**: Code có đúng logic không?
2. **Readability**: Code có dễ hiểu không?
3. **Architecture**: Có tuân thủ kiến trúc không?
4. **Security**: Có lỗ hổng bảo mật không?
5. **Performance**: Có vấn đề hiệu suất không?

**Ví dụ:**
```
User: "Use code-review skill để review function calculateTotal"

Skill sẽ phân tích:

CORRECTNESS:
  ✓ Logic đúng
  ✓ Edge cases handled
  ✗ Bug: Không handle negative numbers

READABILITY:
  ✓ Function name clear
  ✓ Variables well-named
  ✗ Missing comments for complex logic

ARCHITECTURE:
  ✓ Follows single responsibility
  ✓ Proper abstraction level
  ✓ No code duplication

SECURITY:
  ✓ No SQL injection
  ✓ Input validation
  ✓ No secrets hardcoded

PERFORMANCE:
  ✗ Issue: O(n²) instead of O(n)
  ✓ No unnecessary database queries

Feedback:
  - Handle negative numbers
  - Add comments for complex logic
  - Optimize algorithm to O(n)
```

---

#### Skill 15: Code-Simplification

**Mục đích:** Reduce complexity.

**Cách sử dụng:**
```
"Use code-simplification skill to simplify order processing logic"
```

**Techniques:**
- Extract functions
- Reduce nesting
- Use early returns
- Apply design patterns
- Remove dead code

**Ví dụ:**
```
User: "Use code-simplification skill cho function processOrder"

BEFORE (complex):
function processOrder(order) {
  if (order) {
    if (order.items) {
      if (order.items.length > 0) {
        if (order.payment) {
          if (order.payment.status === 'paid') {
            // process order
          }
        }
      }
    }
  }
}

AFTER (simplified):
function processOrder(order) {
  if (!hasValidItems(order)) return;
  if (!isPaid(order)) return;
  // process order
}

function hasValidItems(order) {
  return order?.items?.length > 0;
}

function isPaid(order) {
  return order?.payment?.status === 'paid';
}
```

---

#### Skill 16: Browser-Testing

**Mục đích:** DevTools MCP integration.

**Cách sử dụng:**
```
"Use browser-testing skill to test checkout flow"
```

**Capabilities:**
- Navigate pages
- Fill forms
- Click elements
- Take screenshots
- Test responsive design

**Ví dụ:**
```
User: "Use browser-testing skill để test login form"

Skill sẽ:
1. Open browser (headless or visible)
2. Navigate to /login
3. Fill email: test@example.com
4. Fill password: Test123!
5. Click "Login" button
6. Verify redirected to /dashboard
7. Take screenshot
8. Close browser
```

---

#### Skill 17: Performance-Optimization

**Mục đích:** Measure-first optimization.

**Cách sử dụng:**
```
"Use performance-optimization skill to optimize slow API endpoint"
```

**Process:**
1. **Measure**: Profile and identify bottlenecks
2. **Analyze**: Understand why it's slow
3. **Optimize**: Apply targeted optimizations
4. **Verify**: Confirm improvements

**Ví dụ:**
```
User: "Use performance-optimization skill cho /api/products (3s response)"

MEASURE:
  → Database query: 2.8s
  → API logic: 0.1s
  → Response serialization: 0.1s

ANALYZE:
  → Issue: N+1 query problem
  → Each product loads category separately

OPTIMIZE:
  → Use JOIN to load categories with products
  → Add index on category_id
  → Use pagination

VERIFY:
  → Before: 3s
  → After: 150ms
  → Improvement: 20x faster
```

---

#### Skill 18: E2E-Testing

**Mục đích:** Playwright patterns.

**Cách sử dụng:**
```
"Use e2e-testing skill to write E2E tests for user registration flow"
```

**E2E Test Structure:**
```typescript
test.describe('User Registration', () => {
  test('should register new user', async ({ page }) => {
    // Navigate to registration
    await page.goto('/register');

    // Fill form
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.fill('[name="confirmPassword"]', 'SecurePass123!');

    // Submit
    await page.click('button[type="submit"]');

    // Verify
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome');
  });
});
```

---

#### Skill 19: Security-Audit

**Mục đích:** Vulnerability assessment.

**Cách sử dụng:**
```
"Use security-audit skill to audit payment processing"
```

**Audit Areas:**
- SQL injection
- XSS
- CSRF
- Authentication bypass
- Authorization issues
- Sensitive data exposure

**Ví dụ:**
```
User: "Use security-audit skill cho search functionality"

Skill sẽ kiểm tra:

1. SQL Injection:
   ✓ Input sanitized
   ✓ Parameterized queries used
   ✗ VULNERABLE: Order by clause not sanitized

2. XSS:
   ✓ Output encoded
   ✓ CSP headers set
   ✓ No unsafe innerHTML

3. CSRF:
   ✓ CSRF tokens on POST
   ✓ SameSite cookies

Report:
  - CRITICAL: SQL injection in order by
  - Fix: Use whitelist for sort columns
```

---

#### Skill 20: API-Testing

**Mục đích:** Integration testing cho APIs.

**Cách sử dụng:**
```
"Use api-testing skill to test user API endpoints"
```

**Test Structure:**
```typescript
describe('User API', () => {
  describe('POST /api/users', () => {
    it('should create user with valid data', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          email: 'test@example.com',
          password: 'SecurePass123!',
          name: 'Test User'
        });

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('id');
      expect(response.body.email).toBe('test@example.com');
    });

    it('should reject invalid email', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          email: 'invalid-email',
          password: 'SecurePass123!'
        });

      expect(response.status).toBe(400);
    });
  });
});
```

---

### Workflow Skills (Skills quy trình)

#### Skill 21: Git-Workflow

**Mục đích:** Atomic commits và clean history.

**Cách sử dụng:**
```
"Use git-workflow skill to commit OAuth implementation"
```

**Atomic Commit Rules:**
- One logical change per commit
- Commit message follows Conventional Commits
- Tests included
- Build passes

**Commit Message Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Refactoring
- `test`: Tests
- `docs`: Documentation
- `chore`: Maintenance

**Ví dụ:**
```
User: "Use git-workflow skill để commit OAuth callback implementation"

Skill sẽ tạo commit:

feat(auth): add Google OAuth callback endpoint

- Implement /auth/google/callback endpoint
- Exchange code for tokens
- Create or update user
- Generate JWT session
- Add error handling for invalid codes

Closes #123

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

#### Skill 22: CI-CD-Automation

**Mục đích:** Feature flags, quality gates, deployment.

**Cách sử dụng:**
```
"Use ci-cd-automation skill to setup CI/CD pipeline"
```

**CI Pipeline:**
```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm run lint
      - run: npm run test
      - run: npm run build
```

**Quality Gates:**
- Linting passes
- Tests pass with >80% coverage
- Build succeeds
- Security scan passes

**Feature Flags:**
```typescript
if (featureFlags.isEnabled('new-auth')) {
  // Use new authentication
} else {
  // Use old authentication
}
```

---

#### Skill 23: Documentation

**Mục đích:** ADRs, API docs, code docs.

**Cách sử dụng:**
```
"Use documentation skill to document authentication system"
```

**Documentation Types:**

**1. Architecture Decision Records (ADRs):**
```markdown
# ADR-001: Use JWT for Authentication

## Status
Accepted

## Context
Need to authenticate users across web and mobile.

## Decision
Use JWT tokens for authentication.

## Consequences
- Positive: Stateless, scalable
- Negative: Token revocation requires workarounds
```

**2. API Documentation:**
```markdown
## Authentication

### Login
POST /api/auth/login

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "123",
    "email": "user@example.com"
  }
}
```
```

---

#### Skill 24: Finishing-Branch

**Mục đích:** Merge/PR decisions và cleanup.

**Cách sử dụng:**
```
"Use finishing-branch skill to finish feature/auth-google branch"
```

**Process:**

**1. Final Review:**
- All requirements met?
- All tests passing?
- Code reviewed?
- Documentation updated?

**2. Create PR:**
```bash
gh pr create \
  --title "feat: Add Google OAuth authentication" \
  --body "Implements #123"
```

**3. Merge Decision:**
- Squash and merge (small features)
- Merge commit (larger features)
- Rebase and merge (clean history)

**4. Cleanup:**
```bash
git branch -d feature/auth-google
git fetch origin --prune
```

---

#### Skill 25: Deprecation-Migration

**Mục đích:** Code-as-liability mindset.

**Cách sử dụng:**
```
"Use deprecation-migration skill to migrate from old auth to new auth"
```

**Process:**

**1. Deprecation Plan:**
- Mark as deprecated
- Set deprecation date
- Document migration path

**2. Migration:**
```typescript
// Old (deprecated)
@Deprecated("Use authenticate() instead")
function login(email: string, password: string) {
  // ...
}

// New
function authenticate(credentials: Credentials) {
  // ...
}
```

**3. Communication:**
- Notify team
- Update documentation
- Add migration guide

**4. Removal:**
- After deprecation period
- Remove old code
- Update tests

---

## Ví Dụ Thực Tế

### Example 1: Building a New Feature

```
User: "Tôi muốn thêm tính năng two-factor authentication (2FA)"

Workflow: new-feature

Step 1 - Brainstorm:
  "Use brainstorming skill to explore 2FA implementation"
  → TOTP vs SMS vs Email
  → Decide: TOTP (Google Authenticator)

Step 2 - Spec:
  "Use spec-driven-development skill to create spec"
  → SPEC.md created with:
    - POST /api/auth/2fa/enable
    - POST /api/auth/2fa/verify
    - TOTP secret generation
    - QR code generation

Step 3 - Plan:
  "Agent: planner - Create implementation plan"
  → PLAN.md with 8 tasks

Step 4 - Build:
  "Agent: executor - Implement tasks"
  → T0D cycle for each task
  → Atomic commits

Step 5 - Verify:
  "Agent: code-reviewer - Review implementation"
  "Agent: test-engineer - Verify coverage"
  "Agent: security-auditor - Security audit"
  → All quality gates pass

Step 6 - Ship:
  "Use git-workflow skill to create PR"
  → PR created, reviewed, merged
```

---

### Example 2: Fixing a Bug

```
User: "Bug: User gets logged out randomly after 5 minutes"

Workflow: bug-fix

Step 1 - Investigate:
  "Agent: debugger - Investigate the bug"
  → Reproduced: Session expires after 5 min
  → Logs: JWT token expires after 5 min

Step 2 - Analyze:
  "Agent: debugger - Analyze root cause"
  → Root cause: JWT expiration set to 5 min
  → Expected: Should be 24 hours

Step 3 - Hypothesize:
  "Agent: debugger - Test hypothesis"
  → Hypothesis: Config error in JWT expiration
  → Test: Check JWT config
  → Confirmed: expiresIn: '5m'

Step 4 - Fix:
  "Agent: executor - Fix the issue"
  → Change expiresIn to '24h'
  → Add regression test

Step 5 - Verify:
  "Agent: verifier - Verify fix"
  → Session now lasts 24 hours
  → Bug closed
```

---

### Example 3: Refactoring

```
User: "Refactor user service - it's 2000 lines and hard to maintain"

Workflow: refactoring

Step 1 - Analyze:
  "Agent: code-reviewer - Analyze user service"
  → Issues:
    - Too many responsibilities
    - God object anti-pattern
    - Hard to test

Step 2 - Plan:
  "Agent: planner - Create refactoring plan"
  → Break into:
    - UserService (core logic)
    - UserValidationService
    - UserNotificationService
    - UserRepository

Step 3 - Refactor:
  "Agent: executor - Execute refactoring"
  → Extract services
  → Update tests
  → Maintain behavior

Step 4 - Verify:
  "Agent: test-engineer - Verify no regressions"
  → All tests pass
  → Code more maintainable

Step 5 - Update:
  "Use documentation skill to update docs"
  → Architecture updated
  → ADR created
```

---

## Tips và Best Practices

### Sử dụng Agents, Workflows, Skills hiệu quả:

1. **Start with Workflow** cho tasks lớn, phức tạp
2. **Use Skills** cho tasks cụ thể, isolated
3. **Delegate to Agents** cho specialized work
4. **Combine freely** để fit nhu cầu

### Ví dụ combinations:

```
"Workflow: new-feature cho tính năng payments"
  → Uses brainstorming skill
  → Uses spec-driven-development skill
  → Delegates to planner agent
  → Delegates to executor agent
  → Uses test-driven-development skill
  → Delegates to code-reviewer agent
```

---

## Quick Reference

| Thành phần | Khi nào dùng | Cách gọi |
|-----------|-------------|---------|
| **Workflow** | Tasks lớn, end-to-end | "Workflow: <name> - <description>" |
| **Agent** | Specialized work | "Agent: <name> - <task>" |
| **Skill** | Specific technique | "Use <skill-name> skill to <action>" |

---

## Tài liệu tham khảo

- [CLAUDE.md](./CLAUDE.md) - Main configuration
- [README.md](./README.md) - Project overview
- [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) - What was built

---

**Version:** 1.0.0
**Last Updated:** 2026-04-18
**Language:** Vietnamese

---

🎉 **Chúc bạn sử dụng EM-Skill hiệu quả!**
