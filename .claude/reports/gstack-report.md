# Báo cáo chi tiết về gstack Repository

## Tổng quan về repo

**gstack** là một bộ công cụ AI-assisted engineering workflow được xây dựng bởi Garry Tan (CEO của Y Combinator). Đây không chỉ là một bộ công cụ đơn thuần mà là một hệ sinh thái hoàn chỉnh giúp một người duy nhất có thể vận tốc như một đội 20 người thông qua Claude Code.

### Mục đích chính
- **Tăng tốc độ phát triển**: Giúp developers và founders ship nhanh hơn với tỷ lệ compression từ 20x đến 100x so với traditional team
- **Workflow automation**: Hệ thống 23 specialists + 8 power tools thay thế các vai trò trong một team engineering
- **Multi-AI support**: Hỗ trợ nhiều AI coding agents (Claude, OpenAI Codex, Gemini, OpenClaw, v.v.)

### Cấu trúc tổ chức
```
gstack/
├── skills/               # Các skill chính theo chức năng
│   ├── planning/         # Skills lên kế hoạch (office-hours, plan-*)
│   ├── development/     # Skills phát triển (design-*, codex, guard)
│   ├── review/          # Skills review (review, investigate, cso)
│   ├── testing/         # Skills QA (qa, benchmark, canary)
│   ├── deployment/      # Skills deployment (ship, land-and-deploy)
│   └── tools/           # Power tools (freeze, careful, autoplan)
├── browse/              # Headless browser CLI
├── design/              # Design generation tools
├── bin/                 # CLI utilities
├── hosts/               # Config cho các AI agents khác nhau
├── scripts/             # Build tools và generators
└── test/               # Test infrastructure
```

## Danh sách các skills chính và chức năng

### Planning & Discovery Skills

1. **`/office-hours`** - YC Office Hours
   - Startup mode: 6 câu hỏi forcing để xác định product-market fit
   - Builder mode: Design thinking brainstorming
   - Tạo design doc tự động

2. **`/plan-ceo-review`** - CEO/Founder Review
   - 4 chế độ scope: Expansion, Selective Expansion, Hold Scope, Reduction
   - Tìm kiếm 10-star product ẩn bên trong yêu cầu

3. **`/plan-eng-review`** - Engineering Review
   - Lock architecture, data flow, diagrams
   - Test matrix, failure modes, security concerns

4. **`/plan-design-review`** - Design Review
   - Rate each design dimension 0-10
   - AI slop detection

5. **`/autoplan`** - Review Pipeline
   - Chạy tự động: CEO → design → eng review
   - Tạo plan hoàn chỉnh

### Development Skills

6. **`/design-consultation`** - Design Partner
   - Build design system from scratch
   - Research landscape, propose creative risks
   - Generate realistic product mockups

7. **`/design-shotgun`** - Design Explorer
   - Generate 4-6 AI mockup variants
   - Interactive feedback loop
   - Taste memory học từ preferences

8. **`/design-html`** - Design Engineer
   - Turn mockup vào production HTML
   - Pretext computed layout
   - Zero dependencies, 30KB overhead

9. **`/pair-agent`** - Multi-Agent Coordinator
   - Share browser với bất kỳ AI agent nào
   - Scoped tokens, tab isolation, rate limiting

### Review & Quality Skills

10. **`/review`** - Staff Engineer Review
    - Find bugs that pass CI but blow up in production
    - Auto-fix obvious issues
    - Flag completeness gaps

11. **`/investigate`** - Debugger
    - Systematic root-cause debugging
    - Iron Law: no fixes without investigation
    - Traces data flow, tests hypotheses

12. **`/design-review`** - Designer Who Codes
    - Same audit as /plan-design-review
    - Fixes what it finds
    - Atomic commits, before/after screenshots

13. **`/qa`** - QA Lead
    - Test app, find bugs, fix them
    - Auto-generate regression tests
    - Real browser testing

14. **`/qa-only`** - QA Reporter
    - Same methodology but report only
    - Pure bug report without code changes

### Security & Deployment Skills

15. **`/cso`** - Chief Security Officer
    - OWASP Top 10 + STRIDE threat model
    - 17 false positive exclusions
    - Concrete exploit scenarios

16. **`/ship`** - Release Engineer
    - Sync main, run tests, audit coverage
    - Open PR, bootstrap test frameworks
    - Test-first execution

17. **`/land-and-deploy`** - Release Engineer
    - Merge PR, wait for CI and deploy
    - Verify production health
    - One command from "approved" to "verified"

### Monitoring & Improvement Skills

18. **`/canary`** - SRE Monitoring
    - Post-deploy monitoring loop
    - Watch console errors, performance regressions
    - Page failures detection

19. **`/benchmark`** - Performance Engineer
    - Baseline page load times, Core Web Vitals
    - Compare before/after on every PR

20. **`/retro`** - Engineering Manager
    - Weekly retrospective
    - Per-person breakdowns, shipping streaks
    - Test health trends

21. **`/learn`** - Memory System
    - Manage gstack learnings across sessions
    - Review, search, prune, export patterns
    - Compound learning over time

### Power Tools

22. **`/careful`** - Safety Guardrails
    - Warn before destructive commands
    - Say "be careful" to activate

23. **`/freeze`** - Edit Lock
    - Restrict file edits to one directory
    - Prevent accidental changes while debugging

24. **`/guard`** - Full Safety
    - `/careful` + `/freeze` in one command

25. **`/unfreeze`** - Unlock
    - Remove freeze boundaries

26. **`/document-release`** - Technical Writer
    - Update all project docs to match shipped code
    - Catch stale READMEs automatically

27. **`/codex`** - Second Opinion
    - Independent code review from OpenAI Codex CLI
    - Three modes: review, adversarial challenge, open consultation

28. **`/gstack-upgrade`** - Self-Updater
    - Auto-upgrade gstack to latest
    - Detect global vs vendored installs
    - Show what changed

## Patterns và Best Practices tìm được

### 1. Template-based Documentation System

Pattern: Sử dụng `.tmpl` templates với placeholders để generate SKILL.md files

**Yếu tố thành công:**
- **Single source of truth**: Code → metadata → docs
- **Auto-generated consistency**: Mỗi command trong code đều xuất hiện trong docs
- **Git-friendly**: Template files có thể blame được

**Best practices:**
```yaml
Placeholders: 
  - {{COMMAND_REFERENCE}} → Categorized command table
  - {{SNAPSHOT_FLAGS}} → Flag reference with examples
  - {{PREAMBLE}} → Startup block, update check, session tracking
  - {{QA_METHODOLOGY}} → Shared QA methodology
  - {{BASE_BRANCH_DETECT}} → Dynamic base branch detection
```

### 2. Preamble System

Pattern: Mỗi skill có preamble standard chạy trước logic chính

**Components:**
```bash
# Update check
_UPD=$(gstack-update-check)

# Session tracking
mkdir -p ~/.gstack/sessions
touch ~/.gstack/sessions/"$PPID"

# Telemetry setup
[ "$_TEL" != "off" ] && log usage

# Learnings persistence
load learnings.jsonl if exists

# Timeline logging
record skill start event
```

### 3. Front-loaded Architecture Pattern

Pattern: Check và set-up ở đầu skill để tránh failure giữa chừng

**Flow:**
1. Validate dependencies
2. Set up environment
3. Load configuration
4. Track metrics
5. Then execute main logic

### 4. Design Philosophy Integration

Pattern: ETHOS.md được inject vào mọi skill

**Three Core Principles:**
1. **Boil the Lake**: Complete implementation over shortcuts
2. **Search Before Building**: Three layers of knowledge
3. **User Sovereignty**: AI recommends, users decide

### 5. Testing Architecture

Multi-tier testing system:

| Tier | What | Cost | Speed |
|------|------|------|-------|
| 1 — Static validation | Parse `` commands | Free | <2s |
| 2 — E2E via `claude -p` | Real session tests | ~.85 | ~20min |
| 3 — LLM-as-judge | Sonnet scores docs | ~/bin/zsh.15 | ~30s |

### 6. Multi-Agent Support Pattern

Pattern: Config-driven host detection

**Hosts supported:**
- Claude (primary)
- OpenAI Codex CLI
- OpenClaw
- Cursor
- Factory Droid
- Slate
- Kiro
- Hermes
- GBrain

### 7. Browser Architecture

Pattern: Daemon model với persistent state

**Benefits:**
- ~100ms per command after first call
- Persistent cookies, localStorage, tabs
- Auto-start/stop (30min idle timeout)

### 8. Error Philosophy

Pattern: Errors are for AI agents, not humans

**Principles:**
- Every error must be actionable
- Rewrite internal stack traces
- Guide agents to next step without human intervention

### 9. Security Model

Layered security approach:

1. **Localhost only** - Not reachable from network
2. **Bearer token auth** - Random UUID per session
3. **Cookie security** - macOS Keychain with user approval
4. **Shell injection prevention** - Hardcoded browser registry

### 10. Version Auto-restart Pattern

Pattern: Binary version check triggers server restart

**Implementation:**
- Write `git rev-parse HEAD` to binary
- Check on each CLI invocation
- Auto-restart if version mismatch

## Những gì có thể tái sử dụng cho fullstack engineer

### 1. Template-based Documentation System

**Application:**
- Tạo docs từ code metadata
- Auto-sync API docs khi code changes
- Generate README templates

**Implementation pattern:**
```typescript
// template.tmpl
const [{{COMMANDS}}] = getCommandsFromSource();
// Generate markdown from template + metadata
```

### 2. Multi-Platform Host Detection

**Application:**
- Support nhiều environments (local, staging, production)
- Dynamic tool detection
- Configuration-driven setup

### 3. Error Handling Philosophy

**Application:**
- User-friendly error messages
- Actionable guidance
- Context-aware suggestions

### 4. Session Management

**Application:**
- Track user sessions
- Preserve state across interactions
- Analytics tracking

### 5. Security Model

**Application:**
- Bearer token authentication
- Permission-based access control
- Secure cookie handling

### 6. Testing Architecture

**Application:**
- Multi-tier testing
- Cost-effective CI/CD
- Automated test generation

### 7. Browser Integration Pattern

**Application:**
- E2E testing automation
- Real browser interactions
- Session persistence

### 8. AI Agent Coordination

**Application:**
- Multi-AI workflows
- Tool orchestration
- Agent-to-agent communication

### 9. Performance Monitoring

**Application:**
- Benchmarking workflows
- Performance tracking
- Canary deployment strategies

### 10. Documentation Automation

**Application:**
- Auto-update docs on release
- Generate changelogs
- Maintain API documentation

## Những yếu tố làm gstack độc đáo và hữu ích

### 1. Velocity Multiplier

Tỷ lệ compression từ 20x đến 100x cho các task khác nhau:
- Boilerplate: 100x faster
- Test writing: 50x faster  
- Feature implementation: 30x faster
- Architecture: 5x faster

### 2. Team-in-a-Box

23 specialists thay thế một team engineering:
- CEO/Product Manager
- Lead Designer
- Staff Engineer
- QA Lead
- Security Officer
- Release Engineer

### 3. Process Over Tools

Không chỉ là collection of tools, mà là một process:
**Think → Plan → Build → Review → Test → Ship → Reflect**

### 4. Multi-Agent Compatibility

Hỗ trợ 10+ AI coding agents, không chỉ Claude Code

### 5. Visual Design Pipeline

Từ "I want this" → mockups → production HTML trong 3 bước:
- `/design-shotgun` → explore visually
- `/design-html` → implement HTML/CSS
- Zero dependencies, 30KB overhead

### 6. Memory System

Học và nhớ patterns, pitfalls, preferences qua sessions

### 7. Browser-in-CLI

Real browser integration mà không cần mở browser

### 8. Write Once, Deploy Everywhere

Cấu hình cho staging, production, dev environments

### 9. Quality Gates

Multi-layer quality assurance:
- Static validation
- E2E testing
- LLM review
- Security audit

### 10. Ethos Integration

Builder principles built into every workflow

## Kết luận

gstack không chỉ là một bộ công cụ - đó là một triết lý về cách xây dựng software trong thời đại AI. Nó kết hợp giữa:

1. **Process discipline** - Một quy trình có cấu trúc thay thế team
2. **Quality automation** - Multi-layer quality gates
3. **Velocity multiplier** - 20x-100x compression ratios
4. **Multi-agent support** - Hợp tác giữa nhiều AI systems
5. **Pattern integration** - Best practices built-in

Đối với fullstack engineer, gstack cung cấp:
- Một hệ sinh thái hoàn chỉnh từ planning đến deployment
- Pattern có thể áp dụng cho các dự án khác
- Architecture có thể tái sử dụng
- Methodology có thể scale

Điều quan trọng nhất là gstack chứng minh rằng với AI, một người có thể làm được công việc của cả một team - không phải bằng cách làm nhiều hơn, mà bằng cách thông minh hơn.
