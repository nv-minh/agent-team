---
name: domain-modeling
description: "Extract bounded contexts, entities, relationships, and ubiquitous language from brainstorming output. Use between brainstorming and spec-driven-development to build a conceptual domain model before writing specifications."
version: "1.0.0"
category: "foundation"
origin: "EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "domain model"
  - "bounded context"
  - "ubiquitous language"
  - "entity map"
  - "conceptual design"
  - "domain driven design"
intent: "Bridge the gap between brainstorming output and formal specification by extracting the conceptual domain model — bounded contexts, entities, relationships, and a shared vocabulary."
scenarios:
  - "After brainstorming, before writing specs — understand the domain concepts"
  - "Building a new product from scratch — map the business domain"
  - "Feature crosses multiple subsystems — identify affected contexts"
  - "Ambiguous requirements — clarify by modeling the entities and their relationships"
best_for: "Greenfield projects, complex features with multiple entities, cross-context features, domain understanding"
estimated_time: "30-90 min"
anti_patterns:
  - "Skipping domain modeling because the feature seems simple"
  - "Modeling implementation details instead of business concepts"
  - "Creating one massive context instead of separating concerns"
  - "Writing code before understanding the domain boundaries"
related_skills: [brainstorming, spec-driven-development, alignment-session, diagram]
---

# Domain Modeling

## Overview

Extract a structured domain model from brainstorming output — bounded contexts, entities, relationships, and ubiquitous language. This skill bridges brainstorming (ideation) and spec-driven-development (formal specification) by answering: **what are the core concepts and how do they relate?**

Without domain modeling, specs often skip conceptual clarity, leading to architectural problems discovered during BUILD.

## Hard Gate

**Do NOT proceed to spec-driven-development until the domain model has been reviewed and approved.** The domain model is the conceptual contract between brainstorming and specification.

## When to Use

- After brainstorming, before writing specs (greenfield projects)
- Feature introduces new entities or crosses subsystem boundaries
- Requirements mention domain-specific terms that need precise definition
- User asks "what are the core concepts?" or "how do these things relate?"

**When to SKIP:**
- Small feature within a single, well-understood bounded context
- Internal refactoring with no conceptual changes
- Bug fix with no new entities or relationships

## Process

```
Brainstorming output (design doc)
        ↓
Step 1: Extract Key Concepts
        ↓
Step 2: Identify Bounded Contexts
        ↓
Step 3: Define Entities & Relationships
        ↓
Step 4: Build Ubiquitous Language Glossary
        ↓
Step 5: Validate & Hand Off
        ↓
Domain Model (docs/domain-model.md) → spec-driven-development
```

### Step 1: Extract Key Concepts

Read the brainstorming output (design document at `docs/specs/`). Identify:

- **Nouns** → Candidate entities (User, Order, Payment, Inventory)
- **Verbs** → Candidate actions/processes (Create, Approve, Ship, Refund)
- **Attributes** → Properties of entities (email, status, amount, quantity)
- **Events** → Things that happen (OrderPlaced, PaymentReceived, ItemShipped)

Use the JTBD framework to add context:
- What **functional jobs** does each concept serve?
- What **social/emotional jobs** drive the domain?
- What **pains** does the domain model need to address?

**Output:** Raw concept list with types (Entity / Action / Attribute / Event)

### Step 2: Identify Bounded Contexts

Group related concepts into cohesive domains where:
- Language is consistent (same term means the same thing)
- Responsibility is clear (one thing the context does well)
- Boundaries exist where language or responsibility shifts

Apply the Problem Framing Canvas to validate boundaries:
- **Look Inward:** What assumptions are we making about this context?
- **Look Outward:** Who experiences problems in this area? What are their pain points?
- **Reframe:** Can we simplify by merging or splitting contexts?

Common context patterns:
- **Core Domain** — The reason the product exists, where differentiation happens
- **Supporting Domain** — Necessary but not differentiating (auth, notifications)
- **Generic Domain** — Standard solutions work (email, logging, payments)

**Output:** Context map with context names, responsibilities, and relationships

### Step 3: Define Entities and Relationships

For each bounded context, identify:

**Entity Types:**
- **Aggregate Root** — Primary entity, entry point for the context
- **Entity** — Has identity and lifecycle
- **Value Object** — Defined by attributes, no identity

**Relationships:**
- Type: Association, Composition, Aggregation
- Cardinality: One-to-One, One-to-Many, Many-to-Many
- Direction: Unidirectional, Bidirectional

**Lifecycle States:**
- State machine for stateful entities
- Transitions with triggers and guards

Use the `diagram` skill to generate:
- Entity-Relationship diagram (Mermaid or Excalidraw)
- Context Map diagram showing context relationships
- State diagrams for complex lifecycles

**Output:** Entity definitions with attributes, relationships, and state machines

### Step 4: Build Ubiquitous Language Glossary

For each bounded context, define terms precisely:

| Term | Definition | Context | Related Terms |
|------|-----------|---------|---------------|

Rules:
- **No synonyms** — One term per concept across all contexts
- **No homonyms** — Same term must mean the same thing everywhere
- **Context-qualified** — If a term only applies in one context, note it
- **Cross-referenced** — Link related terms

**Output:** Glossary table integrated into domain model document

### Step 5: Validate and Hand Off

Present the complete domain model for user review:
1. Walk through bounded contexts and their boundaries
2. Show entity relationships with diagrams
3. Review ubiquitous language for clarity and consistency
4. Identify gray areas and discuss with user (one at a time)

Save as `docs/domain-model.md` using the template at `templates/context-artifacts/DOMAIN-MODEL.md`.

Verify:
- Every brainstorming concept maps to a domain entity or is explicitly excluded
- No entity exists without a bounded context
- Ubiquitous language has no synonyms (one term per concept)
- Relationships are documented with cardinality
- State transitions are documented for stateful entities
- User has approved the model

**Hand off to:** `spec-driven-development` skill — every domain entity should map to at least one requirement in the spec.

## Quality Gate Checklist

- [ ] All concepts from brainstorming mapped to entities or explicitly excluded
- [ ] Bounded contexts identified with clear responsibilities
- [ ] Context map shows relationships between contexts
- [ ] Every entity has a type (Aggregate Root / Entity / Value Object)
- [ ] Relationships documented with cardinality
- [ ] State transitions documented for stateful entities
- [ ] Ubiquitous language glossary is complete with no synonyms
- [ ] Diagrams generated (ER, context map, state machines as needed)
- [ ] User has reviewed and approved the domain model
- [ ] Domain model saved to `docs/domain-model.md`

## Coaching Notes

> **ABC - Always Be Coaching:** Every domain modeling decision should teach something about why the boundaries are drawn this way.

1. **Boundaries prevent coupling.** A good bounded context boundary means changes in one context don't cascade into others. Show your human partner how this pays off during implementation.

2. **Ubiquitous language prevents confusion.** When everyone uses the same term for the same concept, meetings are shorter and bugs are fewer. This is the single highest-ROI activity in domain modeling.

3. **Start coarse, refine later.** Don't aim for perfect contexts on day one. 3-5 contexts for a greenfield project is a good start. Refine as you learn more during implementation.

4. **Core domain first.** Identify what makes this product different from competitors. That's the core domain — invest modeling effort there, use generic solutions elsewhere.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Modeling implementation (tables, APIs) instead of business concepts | Ask "would a domain expert understand this?" If not, you're too technical |
| One massive context | Look for where language shifts — that's a boundary |
| Skipping glossary | The glossary IS the domain model's value. Without it, you have diagrams but no shared understanding |
| Perfect contexts on day one | Start with 3-5 coarse contexts, refine during BUILD |
| Including technical concerns in domain model | Auth, logging, caching are supporting/generic domains, not core |

## Verification

After completing domain modeling:

- [ ] Domain model document saved to `docs/domain-model.md`
- [ ] All brainstorming concepts accounted for
- [ ] Bounded contexts with responsibilities documented
- [ ] Entity-relationship diagram generated
- [ ] Ubiquitous language glossary complete
- [ ] User has reviewed and approved
- [ ] Ready to invoke spec-driven-development
