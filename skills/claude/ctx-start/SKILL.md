---
name: ctx start
description: Start a new session in a ContextFun workstream, auto-pull latest transcript, copy a pack, and print a status line.
---

Usage
- `python3 scripts/skills/ctx_start_skill.py --name "<workstream>" --agent claude`
- Optional: `--paste` (macOS) to paste into the frontmost app.

Notes
- Uses local transcript storage (default `~/.claude/projects`, `~/.codex/sessions`).
- Initialize ContextFun with `scripts/quickstart.sh`.

