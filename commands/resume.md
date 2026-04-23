---
description: Re-launch a previously stashed process in its original cwd.
allowed-tools: Bash(claude-processes:*)
---

If `$ARGUMENTS` is empty, run `claude-processes stash list` first and ask the user which snapshot to resume.

Otherwise run `claude-processes unstash $ARGUMENTS` and report the new pid + log file. If the user passed `--attach`, note that the respawned process is now tracked in the current session.
