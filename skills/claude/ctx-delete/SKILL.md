---
name: ctx delete
description: Delete the latest session in a ContextFun workstream, a specific session id, or specific saved entry ids.
---

Usage
- In chat:
  - `/ctx delete <workstream>` — deletes the latest session in that workstream
  - `/ctx delete --session-id <id>` — deletes that specific session
  - `/ctx delete --entry-id E123` — deletes one saved entry from ctx memory
  - `/ctx delete --entry-id E123 --entry-id E122` — deletes multiple saved entries from ctx memory

What it runs
- `bash ./scripts/ctx_delete.sh`
- Falls back to `ctx delete` or `python3 scripts/ctx_cmd.py delete`

Notes
- This is destructive.
- Workstream deletion targets the latest session in the named workstream.
- Entry deletion changes ctx memory only. It does not edit the original Claude/Codex transcript file.
