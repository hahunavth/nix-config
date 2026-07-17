---
description: Safe GC of old generations — dry-run first, explicit confirmation, then delete
---
1. Preview: `nh clean all --keep 5 --dry` and show the user what would be removed/freed.
2. Ask the user for explicit confirmation (this deletes rollback targets older than the last
   5 generations).
3. Only after a clear "yes": `nh clean all --keep 5`. This intentionally triggers a permission
   prompt — it is never pre-approved. Never escalate to `sudo nix-collect-garbage -d` or delete
   store paths manually.
4. Report what was freed (nh output; optionally `df -h /` before/after).
