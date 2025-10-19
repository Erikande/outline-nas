# Scene Ledger

This document tracks the planned vs. actual outcomes for each major project scene.

| Scene | Planned                                                                                                 | Actual                                                                                                                                                                                                                                                                                        | Deltas & Notes                                                                                                                                                                                | Status      |
| :---- | :------------------------------------------------------------------------------------------------------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------- |
| **1** | Bootstrap Outline wiki on NAS, establish dev→prod workflow, and configure private access via Tailscale. | Outline stack is online and stable. Dev→prod workflow is documented, with Makefile and CI guardrails.<br/><br/>**NAS dir scaffold complete (2025-10-02):** Created `/volume1/Docker/outline/{storage,db,redis,uploads}` via host sshd. See [NAS SSH Access Guide](./NAS_SSH_ACCESS_GUIDE.md). | **Backup path deferred**: Creation of `/volume1/Shared/backups/outline` moved to Scene 2.<br/><br/>**Post-mortem:** Overcame Tailscale sandbox issue by using host sshd for filesystem tasks. | **Closed**  |
| **2** | Implement automated backups, deploy Caddy reverse proxy, and automate deployments on Git tag.           | -                                                                                                                                                                                                                                                                                             | -                                                                                                                                                                                             | **Planned** |

### Current Scene Focus — Scene 2 (Utility Layer)

- ✅ Backups scaffold landed: `docker-compose-backups.yml` + `scripts/backup-run.sh`
- ✅ CI job **backups-ci** runs `rclone` **--dry-run** on PRs; uploads `backup_reports/` artifact
- 🔎 Local smoke test:
  ```bash
  docker compose -f docker-compose-backups.yml run --rm -e MODE=--dry-run rclone
  ```

* 📦 NAS prep (for real runs later): confirm/create `/volume1/Shared/backups/outline`
* ➡️ Next: shared Tailscale/MagicDNS hooks, nightly dry-run workflow, retention/include-exclude plan
* ⏭ Deferred (not in Scene 2): real remote credentials & rotation policy
