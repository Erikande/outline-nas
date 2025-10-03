<!-- Copy for GitHub Release: Scene 1—Foundations brings the self-hosted Outline wiki online with a stable, documented, and verifiable dev-to-prod workflow. -->

# Scene 1 — Foundations (Release)

This release marks the successful completion of Scene 1, establishing the foundational infrastructure for the self-hosted Outline wiki. The system is online, stable, and documented, with a clear and repeatable workflow for both local development and production deployment on the NAS.

## What’s Included

- **Finalized Docker Compose Stack**: The `outline`, `postgres`, and `redis` services are configured and stable. The environment variable model (`.env` for local, `.env.prod` for NAS) is finalized.
- **Shared Uploads Mount**: A shared volume (`./storage`) is established for persistent file uploads, ensuring data survives container restarts.
- **Makefile Helpers**: Key management tasks are streamlined with a `Makefile` providing `up`, `down`, `logs`, `health`, and `verify` targets.
- **CI Gates**: The repository is protected with automated checks, including `commitlint` for conventional commits, semantic PR titles, and Jules Checks on the PR head SHA.
- **Health & Verification**: The local stack can be confirmed healthy and correctly configured using `make health` and `make verify`.
- **Core Feature PRs Merged**: All foundational pull requests (#6, #7, #8) have been successfully merged.

## Not Included / Deferred

- **Automated Backups**: The creation and configuration of the `/volume1/Shared/backups/outline` path and associated backup cron jobs are deferred to Scene 2.
- **Caddy Reverse Proxy**: The optional Caddy service for internal TLS is not included in this scene.

## Upgrade/Install Instructions

Installation and deployment procedures are captured in the canonical bootstrap guide.

- **Local Development**: Follow the steps in `SCENE_1_SQUARE_ONE_Outline_NAS_Project.md` to set up your local environment, including creating your `.env` file.
- **NAS (Production) Deployment**: Refer to the "Prod (NAS)" section of the same guide. Ensure you create a `.env.prod` file on the NAS with production secrets.

## Post-mortem & Guardrails

A key challenge in this scene was diagnosing filesystem issues on the NAS. The root cause was a **dual-namespace problem** where `tailscale ssh` connected to a sandboxed Alpine environment, not the ASUSTOR host.

- **The Pitfall:** Creating directories via a Tailscale SSH session resulted in changes within an isolated container, which were not reflected on the host filesystem where Docker volumes were expected.
- **The Fix:** For all host filesystem modifications, use the **host sshd service** by connecting to the NAS's LAN IP (e.g., `ssh admin@192.168.1.196`).
- **Final NAS Layout:** All Docker data directories must exist at `/volume1/Docker/outline/` with `admin:users` ownership and `0775` permissions.
- **Mount Verification:** Before starting the production stack, verify volume mounts are correct using a lightweight probe. See the `Mount Verification Recipes` in the new guide.

For a complete guide on NAS access, user management, and troubleshooting, see the new **[NAS SSH Access Guide](./NAS_SSH_ACCESS_GUIDE.md)**.

## What’s Next

Scene 2 will build upon this foundation by enhancing robustness and automation. The focus will shift to implementing a comprehensive backup strategy for the database and file uploads, deploying an optional Caddy reverse proxy for cleaner internal networking, and potentially automating deployments based on Git tags.
