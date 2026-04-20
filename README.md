# ctx

Local context manager for Claude Code and Codex.

Keep exact conversation bindings, resume work cleanly, branch context without mixing streams, and optionally inspect saved workstreams in a local browser frontend.

```text
Claude Code chat          Codex chat
      |                      |
      v                      v
   /ctx ...               ctx ...
          \              /
           v            v
      +----------------------+
      | workstream: feature-audit |
      |   claude:  abc123    |
      |   codex:   def456    |
      +----------------------+
                 |
                 +--> feature-audit-v2 branch
```

## Why `ctx`

- Exact transcript binding: each internal ctx session can bind to the exact Claude and/or Codex conversation it came from.
- No transcript drift: later pulls stay on that bound conversation instead of jumping to the newest chat on disk.
- Safe branching: start a new workstream from the current state of another one without sharing future transcript pulls or hijacking the source conversation.
- Indexed retrieval: saved workstreams, sessions, and entries are indexed for fast `ctx search` lookup.
- Curated loads: pin saved entries so they always load, exclude saved entries so they stay searchable but stop getting passed back to the model, or delete them entirely.
- Local-first: no API keys, no hosted service, plain SQLite plus local files.

## Quick Install

Clone the repo and do the standard project-local setup:

```bash
git clone https://github.com/dchu917/ctx.git
cd ctx
./setup.sh
```

This is the main development-friendly install path.

It does the following:

- creates `./.contextfun/context.db`
- writes `./ctx.env`
- installs a repo-backed `ctx` shim into `~/.contextfun/bin`
- links local skills into `~/.claude/skills` and `~/.codex/skills`

Use this when:

- you want the repo checked out locally
- you want `ctx` to use a project-local DB by default
- you are developing or editing the repo itself

## 4-Step Demo

1. Clone and set it up:

```bash
git clone https://github.com/dchu917/ctx.git
cd ctx
./setup.sh
```

2. Start a new workstream:

Claude Code:

```text
/ctx start feature-audit --pull
```

Codex or your terminal:

```bash
ctx start feature-audit --pull
```

3. Know what `--pull` means:

- `ctx start feature-audit --pull` creates the workstream and pulls the existing context from the current conversation into it.
- `ctx start feature-audit` creates the workstream starting from that point only. It does not backfill the earlier conversation.

4. Come back later and continue or branch:

Claude Code:

```text
/ctx resume feature-audit
/ctx branch feature-audit feature-audit-v2
```

Codex:

```bash
ctx resume feature-audit
ctx branch feature-audit feature-audit-v2
```

## Daily Use

Claude Code:

- `/ctx`: show the current workstream for this repo, or tell you that none is set yet.
- `/ctx list`: list saved workstreams, with this repo first when applicable.
- `/ctx search dataset download`: search saved workstreams and entries for matching context.
- `/ctx start my-stream --pull`: create a new workstream and pull the existing context from the current conversation into it before continuing.
- `/ctx resume my-stream`: continue an existing workstream and append new context from this conversation to it.
- `/ctx rename better-name`: rename the current workstream.
- `/ctx rename better-name --from old-name`: rename a specific workstream without switching to it first.
- `/ctx delete my-stream`: delete the latest saved `ctx` session in that workstream.
- `/ctx curate my-stream`: open the saved-memory curation UI for that workstream.
- `/ctx branch source-stream target-stream`: create a new workstream seeded from the current saved state of another one.
- `/branch source-stream target-stream`: Claude shortcut for the same branch operation.

Codex:

- `ctx`: show the current workstream for this repo, or tell you that none is set yet.
- `ctx list`: list saved workstreams.
- `ctx list --this-repo`: list only workstreams linked to the current repo.
- `ctx search dataset download`: search saved workstreams and entries for matching context.
- `ctx search dataset download --this-repo`: search only workstreams linked to the current repo.
- `ctx web --open`: open the optional local browser UI for browsing, searching, and copying continuation commands.
- `ctx start my-stream`: create a new workstream starting from this point only.
- `ctx start my-stream --pull`: create a new workstream and pull the existing context from the current conversation into it first.
- `ctx resume my-stream`: continue an existing workstream.
- `ctx resume my-stream --compress`: continue an existing workstream with a smaller load pack.
- `ctx rename better-name`: rename the current workstream.
- `ctx rename better-name --from old-name`: rename a specific workstream without switching to it first.
- `ctx delete my-stream`: delete the latest saved `ctx` session in that workstream.
- `ctx curate my-stream`: open the saved-memory curation UI for that workstream.
- `ctx branch source-stream target-stream`: create a new workstream seeded from the current saved state of another one.

Codex note:

Codex does not currently support repo-defined custom slash commands like `/ctx list`, so in Codex you should use the installed `ctx` command with subcommands. When `ctx start`, `ctx resume`, or `ctx branch` load context, they print a short summary of what the workstream is, the latest session being targeted, and the most recent items. They also include an explicit hint that in Codex you can inspect the full command output with `ctrl-t`, and in Claude you can expand the tool output block, plus guidance for the agent to summarize briefly and ask how you want to proceed instead of pasting the full pack back.

## Other Installation Paths

### Clone the repo and install a shared global setup from that clone

```bash
git clone https://github.com/dchu917/ctx.git
cd ctx
./setup.sh --global
```

This runs the same quickstart entrypoint, but installs the pinned global release into `~/.contextfun` instead of wiring the current clone as the live runtime.

### Install globally without cloning first

```bash
curl -fsSL https://raw.githubusercontent.com/dchu917/ctx/main/scripts/install.sh | bash
```

This installs a pinned tagged release into `~/.contextfun`, including the `ctx` binary, the Python package, the default DB, and the self-contained Claude/Codex skills.

### Install the bootstrap skill first with `skills.sh`

```bash
npx skills add https://github.com/dchu917/ctx --skill ctx -y -g
```

This installs the `ctx` bootstrap skill first, not the CLI binary directly. After that, the bundled `skills/ctx/scripts/ctx.sh` wrapper can run `ctx install` or auto-install the global CLI into `~/.contextfun` on first use.

### Bootstrap an agent shell without a full manual clone flow

Global shell bootstrap:

```bash
source <(curl -fsSL https://raw.githubusercontent.com/dchu917/ctx/main/scripts/agent_bootstrap.sh)
```

Project-local shell bootstrap:

```bash
source <(curl -fsSL https://raw.githubusercontent.com/dchu917/ctx/main/scripts/agent_setup_local_ctx.sh)
```

These are best for Claude Code or Codex terminals.

### Advanced manual wiring after cloning

Repo-backed `ctx` shim:

```bash
bash scripts/install_shims.sh
```

Skill links only:

```bash
bash scripts/install_skills.sh
```

Override skill directories if needed:

```bash
CODEX_SKILLS_DIR=/custom/codex/skills \
CLAUDE_SKILLS_DIR=/custom/claude/skills \
bash scripts/install_skills.sh
```

## Documentation

- [Install and Remove](docs/install.md)
- [Usage](docs/usage.md)
- [Architecture](docs/architecture.md)
- [Integrations](docs/integrations.md)
- [Repo Layout](docs/repo-layout.md)
- [Maintenance and Release](docs/maintenance.md)
- [Documentation Index](docs/README.md)

## Curate Saved Memory

Use `ctx curate <workstream>` to review the saved entries that feed future loads for a workstream:

```bash
ctx curate my-stream
```

The terminal UI lets you scroll saved entries, inspect a preview, and change how each entry behaves in future packs:

- `j` / `k` or arrow keys move through entries
- `Enter` toggles a larger preview
- `p` pins an entry so it always loads, even in compressed mode
- `x` excludes an entry from future loads, but keeps it saved and searchable
- `a` restores the default load behavior
- `d` marks an entry for deletion, then `y` confirms the delete
- `q` exits

Notes:

- This changes ctx memory only. It does not edit or delete the original Claude/Codex chat.
- If you are in a non-interactive shell, use `ctx web --open` and manage entries from the browser detail page instead.
- `ctx delete --interactive <workstream>` opens the same curation UI.
- See [docs/usage.md](docs/usage.md) and [docs/architecture.md](docs/architecture.md) for deeper detail on load controls.

## Clear Workstreams

Use `ctx clear` to delete whole workstreams together with their linked sessions and saved entries:

```bash
ctx clear --this-repo --yes
ctx clear --all --yes
```

Notes:

- `--this-repo` deletes only workstreams linked to the current repo.
- `--all` deletes workstreams across the entire current `ctx` DB.
- `--yes` is required for the actual delete. Without it, `ctx` prints what would be removed and exits without deleting anything.
- This clears ctx-managed memory, attachments, and current-workstream pointers for the deleted workstreams. It does not delete the original Claude/Codex chat files.

## Security

`ctx` is a context layer, not a sandbox. See [SECURITY.md](SECURITY.md) for the threat-model summary and [docs/maintenance.md](docs/maintenance.md) for operational notes.

## FAQ

Do I need API keys?

- No. Everything is local.

Can multiple repos share the same context DB?

- Yes. Set `ctx_DB` to a shared path such as `~/.contextfun/context.db`.

Does deleting a ctx session delete the actual Claude/Codex chat?

- No. It only deletes the internal ctx session and its stored attachments.

## License

MIT. See [LICENSE](LICENSE).
