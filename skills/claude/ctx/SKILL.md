---
name: ctx
description: Chat-friendly commands: /ctx list and /ctx <workstream>
---

Commands
- /ctx list — lists available workstreams
- /ctx <workstream> — resumes that workstream (markdown pack)

Backing script
- `scripts/skills/ctx_cli_skill.sh`
  - `./scripts/skills/ctx_cli_skill.sh list`
  - `./scripts/skills/ctx_cli_skill.sh "<workstream>"`

Requirements
- ContextFun initialized (see `scripts/quickstart.sh`).
- Local transcripts at defaults or via `CODEX_HOME` / `CLAUDE_HOME`.

