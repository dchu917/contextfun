---
name: ctx resume
description: Resume a ContextFun workstream, auto-pull latest Claude/Codex transcript, copy a resume pack, and print a status line.
---

Usage
- In chat:
  - /ctx list — lists workstreams
  - /ctx <workstream> — resumes that workstream (markdown pack)
- Backing command: `scripts/skills/ctx_cli_skill.sh`
  - `./scripts/skills/ctx_cli_skill.sh list`
  - `./scripts/skills/ctx_cli_skill.sh "<workstream>"`

Notes
- Uses local transcript storage (default `~/.claude/projects`, `~/.codex/sessions`).
- Initialize ContextFun with `scripts/quickstart.sh`.
