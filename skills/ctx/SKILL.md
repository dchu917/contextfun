---
name: ctx
description: Use or bootstrap the `ctx` CLI to search, start, resume, rename, delete, branch, and inspect saved coding workstreams.
---

Use this skill when the user wants to recover prior coding context, continue a named workstream, create a new workstream, rename or delete a workstream, branch context, or open the local browser UI.

Requirements:

- If `ctx` is missing, use the bundled wrapper `scripts/ctx.sh`.
- `scripts/ctx.sh install` bootstraps the global install into `~/.contextfun`.
- Any other `scripts/ctx.sh ...` invocation can also auto-install first, then retry the requested command.

Use the single `ctx` entrypoint:

- `ctx install` (skill bootstrap helper; installs the global CLI and bundled skills when needed)
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

- If `ctx` is missing, bootstrap it with `scripts/ctx.sh install` or let the wrapper auto-install on first use.
- `start` creates a new workstream. If the name already exists, ctx automatically creates `name (1)`, `name (2)`, and so on.
- `resume` only continues an existing workstream. If there is no match, say so plainly instead of silently creating a new one.
- When resuming, summarize the workstream briefly, mention the last task and latest relevant activity, and ask how the user wants to proceed.
- Make it explicit that new context from the current conversation will be appended to the resumed workstream.
- If the user wants to explore without changing the source workstream, branch first.
- Use `--this-repo` when the user is asking about context related to the current repository.
