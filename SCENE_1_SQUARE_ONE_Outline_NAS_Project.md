# Scene 1: Square One — Outline NAS Project (Comprehensive & Portfolio-Ready)

> Goal: bootstrap a clean repo + dev environment (VS Code, Warp, Conventional Commits, CI, Jules)
> **and** include the Outline infra + Dev→Prod (NAS) workflow with private access via
> Tailscale/MagicDNS. This file is the authoritative guide for Scene 1.

---

## 🎯 Project Intent (carryover goals)

- **Wiki (Outline) is priority #1** — Docker Compose: Outline + Postgres + Redis; data lives on NAS.
- **Dev → Prod (NAS)** workflow — local on Mac, deploy to NAS, Conventional Commits, CI green.
- **Private access (no public ports)** — Tailscale + MagicDNS; Pixel phone access via Tailscale.
- **Repo = portfolio showcase** — clean commits, README, CI, Jules-assisted PRs.
- **Future scenes (placeholders)** — Obsidian vault sync (separate compose), rclone offsite backups.

This Scene focuses on the **MVP Outline stack** and **Dev→Prod promotion**; future scenes are parked
as TODOs for Jules/you.

---

## 0) Prerequisites (macOS)

- **Git** (via Homebrew): `brew install git`
- **Node LTS + pnpm**: `brew install fnm && fnm install --lts && corepack enable && corepack prepare pnpm@latest --activate`
- **VS Code** installed and signed-in
- **Warp** terminal installed
- **gh** (GitHub CLI): `brew install gh && gh auth login`
- **Tailscale** on Mac + NAS; **MagicDNS** enabled in the Tailscale admin

_Optional_: `brew install jq direnv`, `gh extension install github/gh-copilot`

---

## 1) Create Repo Skeleton

```bash
mkdir -p ~/infra-projects/outline && cd ~/infra-projects/outline
git init -b main
```

Add the provided files from the **starter bundle** (in this repository’s root).

---

## 2) Editor & Tooling Hygiene

- `.editorconfig` for consistent whitespace
- `.vscode/settings.json` + `extensions.json` to standardize formatter & recommendations
- Prettier + ESLint basic config (`.prettierrc.json`, `eslint.config.js`)
- Conventional Commits enforced: commitlint + commitizen (cz-git) + husky hooks
- PR/issue templates; CI (lint/format)

> All config files are included in this bundle. See the folder map at the end.

---

## 3) Conventional Commits (your commit workflow)

- Use `pnpm commit` for an **interactive commit** (cz-git). Enforced by commitlint.
- Husky runs `commitlint` and `lint-staged` on commit.

**Warp tips**  
Add these aliases to `~/.zshrc` (optional):

```sh
alias gc="pnpm commit"
alias gcm="git commit -m"
alias gpom="git push origin main"
```

---

## 4) Outline Stack (MVP)

`docker-compose-outline.yml`:

- Services: **outline**, **postgres**, **redis**
- Volumes mapped to local directories (which, in prod, will be NAS paths)
- Ports: `3000:3000`

### Environment files

- `.env.example` — local dev defaults
- `.env.prod.example` — prod hints (copy to `.env.prod` on the NAS only)

> Never commit `.env` or `.env.prod`.

---

## 5) Dev → Prod (NAS) Promotion Model

**Branches**

- `main` is **deployable**.
- Features on `feat/*` (or `fix/*`) → PR → CI must pass → squash-merge to `main`.

**Dev (local)**

1. `cp .env.example .env` → edit as needed (secrets can be temporary).
2. Run: `docker compose -f docker-compose-outline.yml up -d`
3. Visit: http://localhost:3000

**Prod (NAS)**

1. Clone repo on NAS at `/volume1/Docker/outline`.
2. On NAS only: `cp .env.prod.example .env.prod` and edit real secrets/hostnames.
3. Deploy: `scripts/deploy-prod.sh` (uses `.env.prod`).

Access:

- **LAN**: `http://<NAS-LAN-IP>:3000`
- **Tailscale/MagicDNS**: `http://outline-nas.tailnet-xyz.ts.net:3000` (example)

---

## 6) NFS over Tailscale (Local Mount for Editing)

Use the helper scripts:

- `scripts/mount-outline.sh` — mounts NAS Outline data to `~/nas-outline`.
- `scripts/unmount-outline.sh` — unmounts safely.

These include **Raycast metadata** so you can invoke them as Raycast scripts.

**Auto-mount on login (optional)**  
Install `~/Library/LaunchAgents/com.heather.mount-outline.plist` and load with:

```bash
launchctl load -w ~/Library/LaunchAgents/com.heather.mount-outline.plist
```

> The script gracefully handles “already mounted” or “offline” cases.

---

## 7) Tailscale + MagicDNS + Pixel Access

- Tailscale on **Mac + NAS + Pixel**, connect to your tailnet.
- Enable **MagicDNS**; use hostnames like `outline-nas.tailnet-xyz.ts.net`.
- No public ports or certificates required for private access.
- (Optional later) Add **Caddy** with Tailnet certs if you prefer TLS within Tailnet.

---

## 8) Jules Integration

- `.github/workflows/jules.yml` is a **safe stub** (replace with official action if/when needed).
- `/.jules/TODO.md` includes next-scene tasks for Jules: deploy-on-tag, Caddy reverse proxy, rclone backups, Obsidian compose.

---

## 9) CI (GitHub Actions)

- `ci.yml` runs on PR/push: checkout, Node LTS, pnpm install, lint, and format check.
- Add unit/integration tests later as needed.

---

## 10) First Commit & Push

```bash
git add -A
pnpm install
git commit -m "feat(repo): scene 1 bootstrap with infra, tooling, and dev→prod flow"
# Add remote and push
# git remote add origin git@github.com:<ORG>/<REPO>.git
# git push -u origin main
```

**Branch protection (GitHub → Settings → Branches → main)**

- Require PR before merge, status checks, (optional) linear history.

---

## 11) Folder Map (what’s in this bundle)

```
.
├─ docker-compose-outline.yml
├─ .env.example
├─ .env.prod.example
├─ scripts/
│  ├─ mount-outline.sh
│  ├─ unmount-outline.sh
│  └─ deploy-prod.sh
├─ .editorconfig
├─ .prettierrc.json
├─ eslint.config.js
├─ .vscode/
│  ├─ settings.json
│  └─ extensions.json
├─ .github/
│  ├─ workflows/
│  │  ├─ ci.yml
│  │  └─ jules.yml
│  └─ pull_request_template.md
├─ .jules/
│  └─ TODO.md
└─ launchd/
   └─ com.heather.mount-outline.plist
```

---

## 12) Parking Lot — Scene 2 TODOs (Jules-friendly)

- CI job: **deploy on tag** (prod).
- **Caddy reverse proxy** (optional TLS inside Tailnet).
- Offsite backup (rclone to Proton Drive) for `storage/` + Postgres dumps.
- Obsidian vault sync (Syncthing/WebDAV) as a **separate compose**.
- Add devcontainer for fully reproducible local setup.
- Secret scanning (gitleaks) in CI.

_These are also listed in `/.jules/TODO.md`._

---

## 13) Conventional Commit Cheat-Sheet

- `feat: add new capability`
- `fix: resolve a bug`
- `docs: update docs`
- `chore: tooling/deps`
- `refactor: non-behavior code change`
- `test: add/update tests`
- Scopes (optional): `feat(repo): …`, `fix(ci): …`

---

## 14) Notes & Troubleshooting

- If husky hooks don’t fire: re-run `pnpm dlx husky init` (ensures `.husky/` is linked).
- On macOS, ensure scripts are executable: `chmod +x scripts/*.sh` and `.husky/*`.
- If pnpm install fails in CI, the workflow already sets `corepack enable` and cache; first run may need non-frozen lockfile (already handled in `ci.yml`).

---

**End of Scene 1.** You’re set to start authoring Outline content and migrating your docs.
Next, we’ll layer in Scene 2: Caddy + deploy-on-tag CI + backups + Obsidian compose.
