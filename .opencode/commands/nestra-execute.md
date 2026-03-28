---
description: Execute a Nestra feature with a superpowers-style checklist
agent: build
---

Continue as the Nestra platform engineer.

Load context from:
- AGENTS.md
- README.md
- nestra/README.md
- nestra/DEMO.md
- nestra/WORKFLOW_SUPERPOWERS.md
- nestra/SKILLS_STACK.md
- nestra/docker-compose.yml
- nestra/web/*
- nestra/api/*
- nestra/auth/*

Task: $ARGUMENTS

Execution protocol:
1. Repo context summary
2. Design summary (actor, boundary, guardrail, audit behavior)
3. File plan
4. Implementation in small steps
5. Validation with real commands
6. Follow-up backlog

Do not skip validation.
Do not claim production capabilities that are not implemented.
Use only the Nestra curated skill stack from `nestra/SKILLS_STACK.md`.
