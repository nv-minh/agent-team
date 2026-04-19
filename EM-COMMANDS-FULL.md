# EM-Skill Commands - Complete Reference Guide

## ✅ Tổng Cộng: 29 Commands

### 📊 Phân Loại Commands

#### 1. Agent Commands (11 commands) - Prefix: `em:agent-`
Commands để gọi các chuyên gia AI:

```
/em:agent-planner              -> Create implementation plans
/em:agent-architect            -> Architecture & technical design
/em:agent-backend-expert       -> Backend specialist (API, DB, performance)
/em:agent-frontend-expert      -> Frontend specialist (React, Next.js, UI/UX)
/em:agent-database-expert      -> Database specialist (schema, queries, fintech)
/em:agent-code-reviewer        -> 5-axis code review
/em:agent-debugger             -> Systematic debugging
/em:agent-security-auditor     -> OWASP security audit
/em:agent-test-engineer        -> Test strategy & generation
/em:agent-performance-auditor  -> Benchmarking & optimization
/em:agent-researcher           -> Technical research & exploration
```

**Cách dùng:**
```bash
Use the em:agent-planner skill to create implementation plan for JWT auth
Use the em:agent-backend-expert skill to optimize database queries
Use the em:agent-frontend-expert skill to review React components
```

---

#### 2. Core Workflow Commands (6 commands) - Prefix: `em:`
Workflows phổ biến dùng hàng ngày:

```
/em:new-feature     -> Implement feature from idea to production
/em:bug-fix         -> Fix bugs systematically
/em:refactor        -> Improve code quality
/em:distributed     -> Parallel distributed investigation
/em:team            -> Full team review coordination
/em:incident        -> Production incident response
```

**Cách dùng:**
```bash
Use the em:new-feature skill to implement user authentication
Use the em:bug-fix skill to fix login timeout
Use the em:refactor skill to improve code quality
```

---

#### 3. Specialized Workflow Commands (12 commands) - Prefix: `em:wl-`
Workflows chuyên sâu cho tác vụ phức tạp:

```
/em:wl-architecture-review    -> Architecture review (Architect + Staff Engineer)
/em:wl-design-review           -> UI/UX design review (Frontend + Product Manager)
/em:wl-code-review-9axis       -> Deep 9-axis code review
/em:wl-database-review         -> Database schema & query review
/em:wl-product-review          -> Product/spec review (Product Manager + Architect)
/em:wl-security-review         -> Advanced security (OWASP + STRIDE)
/em:wl-project-setup           -> Initialize new projects
/em:wl-documentation           -> Generate/update documentation
/em:wl-deployment              -> Deploy and monitor features
/em:wl-retro                   -> Retrospective and improvement
/em:wl-distributed-dev         -> Parallel distributed development
/em:wl-security-audit          -> Security audit (OWASP Top 10)
```

**Cách dùng:**
```bash
Use the em:wl-architecture-review skill to review microservices architecture
Use the em:wl-code-review-9axis skill to conduct deep code review
Use the em:wl-security-review skill to conduct threat modeling
```

---

## 🎯 Quick Decision Guide

### Tôi cần gì?

**"Tôi cần tạo kế hoạch"** 
→ `/em:agent-planner`

**"Tôi cần review code/backend/frontend/database"**
→ `/em:agent-code-reviewer`
→ `/em:agent-backend-expert`
→ `/em:agent-frontend-expert`
→ `/em:agent-database-expert`

**"Tôi cần implement feature mới"**
→ `/em:new-feature`

**"Tôi cần fix bug"**
→ `/em:bug-fix`

**"Tôi cần cải thiện code quality"**
→ `/em:refactor`

**"Tôi cần debug lỗi"**
→ `/em:agent-debugger`

**"Tôi cần audit security"**
→ `/em:agent-security-auditor` (basic)
→ `/em:wl-security-review` (advanced)

**"Tôi cần architecture review"**
→ `/em:agent-architect` (quick review)
→ `/em:wl-architecture-review` (full review with team)

**"Tôi cần setup project mới"**
→ `/em:wl-project-setup`

**"Tôi cần deploy"**
→ `/em:wl-deployment`

---

## 📋 Comparison Table

| Type | Prefix | Purpose | Examples | Count |
|------|--------|---------|----------|-------|
| **Agents** | `em:agent-` | Gọi chuyên gia | agent-planner, agent-backend-expert | 11 |
| **Core Workflows** | `em:` | Workflows hàng ngày | new-feature, bug-fix, refactor | 6 |
| **Specialized Workflows** | `em:wl-` | Workflows chuyên sâu | wl-architecture-review, wl-code-review-9axis | 12 |
| **Total** | - | - | - | **29** |

---

## 💡 Usage Tips

### Agent vs Workflow - Khi nào dùng?

**Dùng Agent (`em:agent-*`) khi:**
- Cần chuyên gia cho tác vụ cụ thể
- Chỉ cần 1 chuyên gia, không cần full workflow
- Muốn quick feedback từ chuyên gia

Ví dụ:
```bash
Use the em:agent-backend-expert skill to review API performance
Use the em:agent-frontend-expert skill to refactor React components
```

**Dùng Core Workflow (`em:`) khi:**
- Cần quy trình hoàn chỉnh từ đầu đến cuối
- Task phổ biến hàng ngày
- Muốn tự động hóa quy trình

Ví dụ:
```bash
Use the em:new-feature skill to implement user authentication
Use the em:bug-fix skill to fix login timeout systematically
```

**Dùng Specialized Workflow (`em:wl-`) khi:**
- Cần review từ nhiều chuyên gia (2+ agents)
- Task phức tạp cần coordination
- Cần deep dive analysis

Ví dụ:
```bash
Use the em:wl-architecture-review skill to conduct architecture review with team
Use the em:wl-code-review-9axis skill to conduct deep code review with security
```

---

## 🚀 Most Common Commands (Top 10)

Theo tần suất sử dụng:

1. `/em:agent-planner` - Create plans
2. `/em:agent-backend-expert` - Backend work
3. `/em:agent-frontend-expert` - Frontend work
4. `/em:new-feature` - Implement features
5. `/em:bug-fix` - Fix bugs
6. `/em:agent-code-reviewer` - Review code
7. `/em:agent-debugger` - Debug issues
8. `/em:refactor` - Improve quality
9. `/em:agent-database-expert` - Database work
10. `/em:agent-security-auditor` - Security audit

---

## 🔍 Naming Convention

### Agents: `em:agent-[role]`
- `em:agent-planner` - Planner agent
- `em:agent-backend-expert` - Backend expert agent
- `em:agent-frontend-expert` - Frontend expert agent

### Core Workflows: `em:[workflow-name]`
- `em:new-feature` - New feature workflow
- `em:bug-fix` - Bug fix workflow

### Specialized Workflows: `em:wl-[workflow-name]`
- `em:wl-architecture-review` - Architecture review workflow
- `em:wl-code-review-9axis` - 9-axis code review workflow

**Prefix meanings:**
- `agent-` = Single agent specialist
- (no prefix) = Core workflow (common tasks)
- `wl-` = Workflow Level (specialized, multi-agent)

---

## ✅ Verification

Reload Claude Code session và kiểm tra **system reminder**. Bạn sẽ thấy tất cả 29 commands!

---

## 📚 Related Documentation

- `README.md` - Main project documentation
- `INSTALLATION.md` - Installation guide
- `docs/guides/usage-guide.md` - Comprehensive usage guide
