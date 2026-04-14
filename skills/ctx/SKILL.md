---
name: ctx
description: Use the local ctx CLI to search, start, resume, rename, delete, branch, and inspect saved coding workstreams. Requires the `ctx` command to be installed on the machine.
---

Use this skill when the user wants to recover prior coding context, continue a named workstream, create a new workstream, rename or delete a workstream, branch context, or open the local browser UI.

Requirements:

- `ctx` must already be installed.
- If `ctx` is missing, tell the user to run `./setup.sh` in a clone of the repo or use the global installer from `https://github.com/dchu917/ctx`.

Use the single `ctx` entrypoint:

- `ctx`
- `ctx list [--this-repo]`
- `ctx search <query> [--this-repo]`
- `ctx start <workstream> [--pull]`
- `ctx resume <workstream> [--compress] [--allow-other-repo]`
- `ctx rename <new-name> [--from <existing-workstream>]`
- `ctx delete <workstream>` or `ctx delete --session-id <id>`
- `ctx branch <source-workstream> <target-workstream> [--allow-other-repo]`
- `ctx web --open`

The bundled wrapper is available as `scripts/ctx.sh <subcommand> ...`.

Behavior:

- `start` creates a new workstream. If the name already exists, ctx automatically creates `name (1)`, `name (2)`, and so on.
- `resume` only continues an existing workstream. If there is no match, say so plainly instead of silently creating a new one.
- When resuming, summarize the workstream briefly, mention the last task and latest relevant activity, and ask how the user wants to proceed.
- Make it explicit that new context from the current conversation will be appended to the resumed workstream.
- If the user wants to explore without changing the source workstream, branch first.
- Use `--this-repo` when the user is asking about context related to the current repository.
