# Environment Expectations — HTTPS & Access (Tailscale + MagicDNS)

Defines how Outline is accessed in each environment and the required HTTPS story. This is requirements/contract only (no code).

## Environments

- **Pre-prod (Local/Dev)** — developer laptop, loopback access.
- **Prod (NAS)** — Synology/NAS, tailnet-only access via **Tailscale + MagicDNS**.

---

## 1) Pre-prod (Local/Dev)

**Access model**

- Browser origin: `http://localhost:3000` (loopback), no Tailscale, **no TLS**.

**Must**

- `URL=http://localhost:3000` (app's URL must equal the browser origin).
- `FORCE_HTTPS=false` (no HTTPS enforcement in dev).
- Visit **localhost** (not 127.0.0.1) to match CSP.
- Cookies not `Secure` (HTTP origin).

**Won't**

- No local reverse proxy, no local certs, no public exposure.

**Success**

- `http://localhost:3000` returns 200/302; UI loads with **no CSP errors**; `make health` / `make verify` pass.

---

## 2) Prod (NAS)

**Access model**

- Browser origin: `https://outline.tailnet-name.ts.net` (Tailscale MagicDNS), **TLS required**.
- Only accessible from devices on the tailnet.

> **Note on Administrative Access:** Application access (HTTPS via MagicDNS) is distinct from administrative shell access (SSH). For filesystem changes on the NAS, always use the host's LAN-based SSH service to avoid sandboxing issues. For complete details, see the **[NAS SSH Access Guide](./NAS_SSH_ACCESS_GUIDE.md)**.

**Must**

- `URL=https://outline.tailnet-name.ts.net` (app's URL must equal the browser origin).
- `FORCE_HTTPS=true` (enforce HTTPS in production).
- Valid TLS certificate for `*.ts.net` domain (Tailscale provides this automatically).
- Cookies must be `Secure` (HTTPS origin).
- CSP headers compatible with HTTPS origin.

**Won't**

- No public internet access (tailnet-only).
- No custom domain/DNS (using Tailscale MagicDNS).
- No manual certificate management (Tailscale handles TLS).

**Success**

- `https://outline.tailnet-name.ts.net` returns 200/302 from tailnet devices.
- UI loads with no CSP/mixed-content errors.
- All cookies properly secured.
- Health checks pass from within tailnet.

---

## Environment Variables Summary

| Variable        | Pre-prod (Local/Dev)    | Prod (NAS)                            |
| --------------- | ----------------------- | ------------------------------------- |
| `URL`           | `http://localhost:3000` | `https://outline.tailnet-name.ts.net` |
| `FORCE_HTTPS`   | `false`                 | `true`                                |
| Cookie `Secure` | `false`                 | `true`                                |
| TLS Certificate | N/A                     | Auto-managed by Tailscale             |

---

## Security Considerations

**Pre-prod**

- HTTP acceptable for local development only.
- No sensitive data should be used in local environment.
- Firewall should block external access to port 3000.

**Prod**

- HTTPS mandatory for production data.
- Tailscale provides network-level access control.
- Regular security updates for NAS and Tailscale client.
- Monitor tailnet access logs.

---

## Troubleshooting

**Common CSP Issues**

- Ensure `URL` exactly matches browser origin (including protocol, hostname, port).
- Check for mixed HTTP/HTTPS content in HTTPS environments.
- Verify CSP headers allow the correct origin.

**Tailscale Connectivity**

- Confirm MagicDNS is enabled on tailnet.
- Verify device is connected to tailnet (`tailscale status`).
- Check firewall rules on NAS for port access.
- Ensure Tailscale certificate is valid and auto-renewed.
