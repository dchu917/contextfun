---
name: ctx resume
description: Resume a ContextFun workstream, auto-pull latest Claude/Codex transcript, copy a resume pack, and print a status line.
---

Usage
- `python3 scripts/skills/ctx_resume_skill.py --name "<workstream>"`
- Optional: `--paste` (macOS) to paste into the frontmost app.

Notes
- Uses local transcript storage (default `~/.claude/projects`, `~/.codex/sessions`).
- Initialize ContextFun with `scripts/quickstart.sh`.

