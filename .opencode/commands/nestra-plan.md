---
description: Plan a Nestra slice without editing code
agent: plan
---

Analyze the Nestra repo for this task: $ARGUMENTS

Load context from:
- AGENTS.md
- README.md
- nestra/README.md
- nestra/DEMO.md
- nestra/docker-compose.yml
- nestra/web/*
- nestra/api/*
- nestra/auth/*

Do not modify code.

Return:
1. current architecture relevant to the task
2. missing foundation
3. proposed approach
4. file-by-file implementation plan
5. risks / assumptions
6. best next slice
