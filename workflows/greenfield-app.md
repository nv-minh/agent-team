---
name: greenfield-app
description: Complete workflow from blank directory to shipped application. Covers ideation, problem reframing, domain modeling, requirements, architecture, bootstrapping, implementation, and launch.
version: "1.0.0"
category: "primary"
origin: "EM-Team"
agents_used:
  - product-manager
  - architect
  - planner
  - executor
  - verifier
  - test-engineer
  - market-intelligence
skills_used:
  - brainstorming
  - domain-modeling
  - spec-driven-development
  - alignment-session
  - writing-plans
  - test-driven-development
  - subagent-driven-development
  - code-review
  - git-workflow
related_skills:
  - domain-modeling
  - spec-driven-development
  - project-setup
estimated_time: "1-2 weeks (MVP) / 4-8 weeks (full product)"
---

# Greenfield App Workflow

## Overview

Build an application from scratch — from blank directory to shipped product. This workflow covers the full lifecycle that existing workflows skip: ideation validation, problem reframing, domain modeling, and strategic architecture before any code is written.

## When to Use

- Building a new product from scratch
- Starting a greenfield project with no existing codebase
- Creating a new application or service
- Proof of concept that may become production

**When NOT to use:**
- Adding features to existing codebase → use `new-feature`
- Technical bootstrapping only → use `project-setup`
- Market-driven feature in existing product → use `market-driven-feature`

## Decision Framework

| Starting Point | Workflow |
|---|---|
| Blank directory + idea | **greenfield-app** (this one) |
| Existing codebase + feature | new-feature |
| Existing codebase + market opportunity | market-driven-feature |
| Technical bootstrapping only | project-setup |

## Lifecycle

```
DEFINE ──────────────────→ PLAN ──────────→ BUILD ────────→ VERIFY → REVIEW → SHIP
  Stage 1: Ideation        Stage 4: Spec     Stage 6: Setup   Stage 8  Stage 9  Stage 10
  Stage 2: Reframing       Stage 5: Arch     Stage 7: Build
  Stage 3: Domain Model
     │                        │                 │            │        │        │
     ▼                        ▼                 ▼            ▼        ▼        ▼
  GATE 1                   GATE 2           GATE 3       GATE 4   GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Description |
|---|---|---|
| IDEATION (Stage 1) | DEFINE | Validate idea, answer "should we build this?" |
| REFRAMING (Stage 2) | DEFINE | Reframe problem, explore design approaches |
| DOMAIN MODEL (Stage 3) | DEFINE | Extract bounded contexts, entities, relationships |
| SPEC (Stage 4) | PLAN | Write specification with requirements |
| ARCHITECTURE (Stage 5) | PLAN | Design system, create phased roadmap |
| BOOTSTRAP (Stage 6) | BUILD | Technical setup — delegates to project-setup |
| IMPLEMENT (Stage 7) | BUILD | Execute roadmap phases with TDD |
| VALIDATE (Stage 8) | VERIFY | Full verification against spec and domain model |
| REVIEW (Stage 9) | REVIEW | Multi-agent code, architecture, security review |
| LAUNCH (Stage 10) | SHIP | PR, deploy, monitor — delegates to ship-workflow |

## Workflow Stages

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│  IDEATION → REFRAME → DOMAIN → SPEC → ARCH → BOOTSTRAP → BUILD → VAL → REV → LAUNCH │
│     1          2        3       4       5        6         7      8      9     10   │
│                                                                                 │
│  ─── DEFINE ──→ ──── PLAN ────→ ────── BUILD ──────→ VERIFY → REVIEW → SHIP   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Stage 1: Ideation and Validation

**Agent:** product-manager
**Skill:** office-hours

**Process:**
1. Present the six forcing questions:
   - **Demand reality**: What evidence exists that people want this?
   - **Status quo bias**: Why aren't existing solutions good enough?
   - **Narrowest wedge**: What's the smallest version that proves value?
   - **Observation**: How will you know if this is working?
   - **Future-fit**: Does this get harder or easier as the market evolves?
   - **Personal fit**: Why are you the right person/team to build this?
2. Challenge assumptions — listen for pain points, not feature requests
3. Generate 2-3 alternative framings of the problem
4. Make a falsifiable claim about the product hypothesis

**Output:**
- Validated idea brief with hypothesis
- Go/No-Go decision documented
- Alternative framings considered

**Quality Gate:**
- [ ] Idea hypothesis stated as a falsifiable claim
- [ ] At least one alternative framing explored
- [ ] Go/No-Go decision made
- [ ] If No-Go: workflow ends, pivot considered

---

## Stage 2: Problem Reframing and Design

**Agent:** product-manager + architect
**Skill:** brainstorming

**Process:**
1. Reframe the problem using the Problem Framing Canvas:
   - **Look Inward**: What assumptions are we making?
   - **Look Outward**: Who experiences this problem? How often?
   - **Reframe**: Create actionable problem statement
2. Brainstorm 2-3 solution approaches with trade-offs
3. Present design section by section, get user approval
4. Write design document

**Output:**
- Design document at `docs/specs/YYYY-MM-DD-<topic>-design.md`
- Problem reframing notes
- Selected approach with rationale

**Quality Gate:**
- [ ] Problem reframed with actionable statement
- [ ] 2-3 approaches explored with trade-offs
- [ ] User approved selected approach
- [ ] Design document written and committed

---

## Stage 3: Domain Modeling

**Agent:** architect + planner
**Skill:** domain-modeling

**Process:**
1. Extract key concepts from brainstorming output
2. Identify bounded contexts (Core / Supporting / Generic)
3. Define entities, relationships, lifecycle states
4. Build ubiquitous language glossary
5. Generate diagrams (ER, context map, state machines)
6. Present for user review

**Output:**
- Domain model at `docs/domain-model.md`
- Bounded context map
- Entity-relationship diagrams
- Ubiquitous language glossary

**Quality Gate:**
- [ ] All brainstorming concepts mapped to entities or excluded
- [ ] Bounded contexts identified with clear responsibilities
- [ ] Entities have types (Aggregate Root / Entity / Value Object)
- [ ] Relationships documented with cardinality
- [ ] Ubiquitous language glossary complete (no synonyms)
- [ ] User approved the domain model

---

## Stage 4: Requirements and Specification

**Agent:** planner
**Skill:** spec-driven-development

**Process:**
1. Read design document and domain model
2. Map every domain entity to requirement areas
3. Write structured specification:
   - Functional requirements (linked to domain entities)
   - Non-functional requirements
   - Success criteria (testable)
   - Boundaries (in-scope / out-of-scope)
4. Group features by category, scope as v1 / v2 / out-of-scope
5. Generate REQUIREMENTS.md with REQ-IDs

**Output:**
- SPEC.md document
- REQUIREMENTS.md with traceable REQ-IDs
- Success criteria defined

**Quality Gate:**
- [ ] Every domain entity maps to at least one requirement
- [ ] Requirements traceable (REQ-IDs)
- [ ] v1 scope defined with clear boundaries
- [ ] Success criteria testable
- [ ] User approved spec

---

## Stage 5: Architecture and Roadmap

**Agent:** architect + planner
**Skill:** writing-plans

**Process:**
1. Design system architecture from domain model:
   - Bounded contexts → modules/services
   - Entity relationships → data model
   - Actions → API endpoints / commands
2. Run architecture review (CEO scope check + Eng review):
   - Scope: Is this the right scope, or are we over/under-building?
   - Data flow: How does information move through the system?
   - Failure modes: What breaks and how do we recover?
3. Create phased roadmap:
   - Each phase = 1-2 atomic plans
   - Dependencies between phases explicit
   - First phase = thinnest viable slice
4. Generate ARCHITECTURE.md and ROADMAP.md

**Output:**
- ARCHITECTURE.md (system design, data flow, failure modes)
- ROADMAP.md (phased delivery plan)
- Architecture diagrams

**Quality Gate:**
- [ ] Architecture covers all bounded contexts
- [ ] Data flow documented
- [ ] Failure modes identified with recovery plans
- [ ] Roadmap phases map to v1 requirements
- [ ] First phase is the thinnest viable slice
- [ ] User approved architecture and roadmap

---

## Stage 6: Technical Bootstrapping

**Agent:** planner + executor
**Workflow:** delegates to `project-setup`

**Process:**
1. Delegate to the project-setup workflow:
   - CHOOSE → SCAFFOLD → CONFIGURE → TEST → INITIALIZE
2. Tech stack selected based on Stage 5 architecture decisions
3. Project structure aligned with bounded contexts from Stage 3

**Output:**
- Initialized project with working tooling
- CI/CD pipeline active
- Repository with branch protections

**Quality Gate:**
- [ ] Project scaffolded and configured
- [ ] Build passes
- [ ] CI/CD active
- [ ] Repository initialized

---

## Stage 7: Core Implementation

**Agent:** executor
**Skill:** subagent-driven-development, test-driven-development

**Process:**
Execute roadmap phases from Stage 5 using wave-based parallelization:
- Independent phases → parallel execution
- Dependent phases → sequential execution

Per phase:
1. **Discuss** — Identify implementation gray areas, capture decisions in CONTEXT.md
2. **Plan** — Create detailed plan with tasks (XML format), verify against requirements
3. **Execute** — Implement with TDD (RED → GREEN → REFACTOR), atomic commits
4. **Verify** — Check acceptance criteria, run tests

**Output:**
- Working code per roadmap phase
- Tests for all implemented features
- Atomic commits with descriptive messages

**Quality Gate:**
- [ ] All phase acceptance criteria met
- [ ] Tests passing (unit + integration)
- [ ] No TODOs or placeholders in code
- [ ] Atomic commits with clear messages

---

## Stage 8: Validation

**Agent:** verifier + test-engineer

**Process:**
1. Verify spec coverage — every requirement has a working implementation
2. Cross-check domain model — every entity has a working implementation
3. Run full test suite (unit + integration + E2E)
4. Test acceptance criteria
5. Edge case testing
6. User acceptance testing

**Output:**
- Verification report
- Test coverage report
- Domain model ↔ implementation cross-check

**Quality Gate:**
- [ ] Spec coverage 100%
- [ ] Every domain entity implemented
- [ ] All acceptance criteria met
- [ ] No regressions
- [ ] User acceptance testing passed

---

## Stage 9: Multi-Agent Review

**Agent:** code-reviewer (Deep mode), security-reviewer, architect

**Process:**
Sequential review pipeline:
1. **Architecture review** — Does implementation match architecture? Any drift?
2. **Code review (Deep mode, 9-axis)** — Correctness, readability, architecture, security, performance, testing, maintainability, scalability, documentation
3. **Security review** — OWASP Top 10 + STRIDE threat modeling

**Output:**
- Architecture review report
- Code review report with scores
- Security review report with scorecard

**Quality Gate:**
- [ ] No critical findings in any review
- [ ] High findings have remediation plan
- [ ] Architecture matches design (no drift)
- [ ] Security scorecard acceptable

---

## Stage 10: Launch

**Agent:** executor
**Workflow:** delegates to `ship-workflow`

**Process:**
1. Delegate to ship-workflow:
   - Final verification
   - Version bump
   - PR creation
   - Merge
   - Deploy
   - Canary monitoring

**Output:**
- PR merged
- Deployed to production
- Monitoring healthy

**Quality Gate:**
- [ ] PR merged
- [ ] Deployed successfully
- [ ] Monitoring shows healthy state
- [ ] No production errors

---

## Handoff Contracts

### Stage 1 → Stage 2

```yaml
handoff:
  from: product-manager
  to: product-manager + architect
  provides:
    - validated_idea_brief
    - go_no_go_decision
    - alternative_framings
  expects:
    - design_document
    - selected_approach
```

### Stage 2 → Stage 3

```yaml
handoff:
  from: product-manager + architect
  to: architect + planner
  provides:
    - design_document
    - user_approval
  expects:
    - domain_model
    - bounded_contexts
    - ubiquitous_language
```

### Stage 3 → Stage 4

```yaml
handoff:
  from: architect + planner
  to: planner
  provides:
    - domain_model
    - bounded_contexts
    - entity_relationships
    - ubiquitous_language
  expects:
    - spec_document
    - requirements_with_traceability
```

### Stage 4 → Stage 5

```yaml
handoff:
  from: planner
  to: architect + planner
  provides:
    - spec_document
    - requirements
  expects:
    - architecture_document
    - roadmap
```

### Stage 5 → Stage 6

```yaml
handoff:
  from: architect + planner
  to: planner + executor
  provides:
    - architecture_document
    - roadmap
    - tech_stack_decisions
  expects:
    - initialized_project
    - cicd_active
```

### Stage 6 → Stage 7

```yaml
handoff:
  from: planner + executor
  to: executor
  provides:
    - initialized_project
    - roadmap
    - domain_model
    - spec_document
  expects:
    - working_code
    - tests_passing
```

---

## Timeline Estimate

```yaml
timeline:
  ideation: "1-3 hours"
  reframing: "2-4 hours"
  domain_modeling: "2-6 hours"
  spec: "2-4 hours"
  architecture: "3-6 hours"
  bootstrapping: "3-7 hours"
  implementation: "1-6 weeks (depends on scope)"
  validation: "4-8 hours"
  review: "4-8 hours"
  launch: "2-4 hours"

  total_mvp: "1-2 weeks"
  total_full_product: "4-8 weeks"
```

---

## Quality Gates Summary

```yaml
quality_gates:
  ideation:
    - hypothesis_falsifiable
    - alternative_framings_explored
    - go_no_go_decision_made

  reframing:
    - problem_reframed
    - approaches_explored
    - design_approved
    - design_document_written

  domain_model:
    - all_concepts_mapped
    - bounded_contexts_identified
    - entities_typed
    - relationships_documented
    - ubiquitous_language_complete
    - user_approved

  spec:
    - every_entity_mapped_to_requirement
    - requirements_traceable
    - v1_scope_defined
    - success_criteria_testable
    - user_approved

  architecture:
    - architecture_covers_contexts
    - data_flow_documented
    - failure_modes_identified
    - roadmap_phases_map_to_requirements
    - user_approved

  bootstrapping:
    - project_scaffolded
    - build_passes
    - cicd_active
    - repository_initialized

  implementation:
    - acceptance_criteria_met
    - tests_passing
    - no_todos_or_placeholders
    - atomic_commits

  validation:
    - spec_coverage_100
    - domain_model_covered
    - acceptance_criteria_met
    - user_acceptance_passed

  review:
    - no_critical_findings
    - architecture_no_drift
    - security_acceptable

  launch:
    - pr_merged
    - deployed
    - monitoring_healthy
```

---

## Success Criteria

A successful greenfield app workflow:

- [ ] Product idea validated through structured questioning
- [ ] Problem reframed with clear design approach
- [ ] Domain model complete with bounded contexts and ubiquitous language
- [ ] Specification covers all domain entities with traceable requirements
- [ ] Architecture matches domain model and addresses failure modes
- [ ] Phased roadmap delivered with thinnest viable slice first
- [ ] Project bootstrapped with proper tooling and CI/CD
- [ ] All v1 requirements implemented and tested
- [ ] Multi-agent review passed with no critical findings
- [ ] Deployed to production with healthy monitoring

---

**Version:** 1.0.0
**Last Updated:** 2026-05-08
**Status:** Production Ready
