---
name: em:checkpoint
description: Save and restore working state checkpoints - EM-Team Command
tags: [checkpoint, state, git, em-team]
always_available: true
---

# EM:Checkpoint - State Management

Save and restore working state with git checkpoints.

## Usage

```
Use the em:checkpoint skill to save checkpoint [name]
Use the em:checkpoint skill to restore checkpoint [name]
Use the em:checkpoint skill to list checkpoints
Use the em:checkpoint skill to delete checkpoint [name]
```

## Examples

```
Use the em:checkpoint skill to save checkpoint feature-start
Use the em:checkpoint skill to restore checkpoint feature-start
Use the em:checkpoint skill to list all checkpoints
```

## What This Does

- **save** — Captures current git state (branch, commit, timestamp)
- **restore** — Checks out the saved branch and commit
- **list** — Shows all saved checkpoints with details
- **delete** — Removes a checkpoint

## Note

Checkpoints save git state only (branch, commit). They do not save uncommitted changes or files.
