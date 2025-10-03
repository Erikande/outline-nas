# NAS SSH Access Guide

This guide provides the canonical steps for accessing the ASUSTOR NAS for administrative tasks. It covers which account, IP address, and DNS names to use, and how to avoid common pitfalls with Tailscale's sandboxed environment on ASUSTOR devices.

## 1. Access Matrix

| Environment   | Primary Access (UI)                                    | Shell Access (CLI)                                                                                                                                               |
| :------------ | :----------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Dev/Local** | `http://localhost:3000`                                | Local terminal only.                                                                                                                                             |
| **Prod/NAS**  | MagicDNS: `https://<device>.<tailnet-suffix>` (future) | **Host sshd (LAN):** `ssh admin@<LAN-IP>` (e.g., `192.168.1.196`).<br/>**Tailscale SSH:** `ssh admin@<MagicDNS>` (use only when host user mapping is confirmed). |

## 2. Which User to Use (and When)

- **`admin` (Preferred):** Use for most host-level tasks. This user should be added to the `docker` group for managing containers.
- **`root`:** Use only for short, controlled operations that strictly require it. Root login via SSH should be disabled immediately after use.
- **App Users (e.g., `marlon`):** Not required for infrastructure setup. These are application-level accounts.

## 3. Tailscale SSH on ASUSTOR (One-Time Enable & ACL)

To enable Tailscale SSH, you must run the command within the `tailscaled` namespace on the NAS.

1.  **Enable SSH Server:**

    ```sh
    # Find the tailscaled process ID
    ps | grep tailscaled
    # Enter the namespace and enable SSH
    nsenter -t <PID> -n tailscale set --ssh=true
    # Or, use the socket directly
    tailscale --socket /proc/<PID>/root/run/tailscale/tailscaled.sock set --ssh=true
    ```

2.  **Configure ACLs:** Add the following to your Tailscale policy file to grant access.

    ```json
    {
      "tagOwners": {
        "tag:nas": ["<your-email>", "autogroup:admin"]
      },
      "ssh": [
        {
          "action": "accept",
          "src": ["<your-email>"],
          "dst": ["tag:nas"],
          "users": ["admin", "root"]
        },
        {
          "action": "check",
          "src": ["autogroup:member"],
          "dst": ["autogroup:self"],
          "users": ["autogroup:nonroot", "root"]
        }
      ]
    }
    ```

3.  **Tag Device:** Apply the `tag:nas` in the Tailscale Admin Console to the ASUSTOR device.

## 4. ASUSTOR Nuance: Sandbox vs. Host

A critical issue on ASUSTOR is that the Tailscale package may run in a separate Alpine Linux container. SSHing via Tailscale can land you in this sandbox, not on the host.

- **Symptom:** The SSH banner shows "Alpine Linux," and the filesystem layout is different (e.g., `/volume1` does not match the host's shared folders).
- **Rule:** For any changes to the host filesystem (like creating Docker volumes), **always use the host's SSH server on its LAN IP.**
- **Verification:** Create a "beacon" file on the host (`touch /volume1/Docker/.host_beacon`) and check if it appears in both your SSH session and the ADM File Explorer.

## 5. Host sshd Hardening Policy

- **Disable Root Login:** Only enable root login for specific, temporary tasks. Disable it from **ADM → Services → SSH** immediately afterward.
- **Prefer Tailscale SSH:** For non-filesystem commands, Tailscale SSH is convenient, provided it correctly maps to host users.

## 6. Grant Docker Access to `admin`

To allow the `admin` user to manage Docker without `sudo`, add it to the `docker` group. This is a one-time setup.

```sh
# Add the 'docker' group if it doesn't exist
addgroup docker 2>/dev/null || true
# Add 'admin' to the 'docker' group
adduser admin docker 2>/dev/null || gpasswd -a admin docker
```

You must log out and log back in for the group membership to take effect.

## 7. Scene 1 Directory Contract (NAS)

The following directory structure is required for the Outline stack on the NAS.

- **Required Layout:**
  ```
  /volume1/Docker/outline/
  ├── storage
  ├── db
  ├── redis
  └── uploads
  ```
- **Ownership & Permissions:** `admin:users`, `0775`.
- **Idempotent Creation (POSIX sh):**
  ```sh
  # Use an explicit list for portability (no brace expansion)
  for dir in storage db redis uploads; do
    mkdir -p "/volume1/Docker/outline/${dir}"
    chown admin:users "/volume1/Docker/outline/${dir}"
    chmod 0775 "/volume1/Docker/outline/${dir}"
  done
  ```

## 8. Mount Verification Recipes

- **Dev (Local):**
  ```sh
  # Write a file from a temporary container into the mount
  docker-compose run --rm outline sh -c 'echo "dev_ok" > /var/lib/outline/data/.probe'
  # Verify it appears on the host
  cat ./storage/.probe
  ```
- **NAS (Production):**
  ```sh
  # Run a lightweight container to touch a file in the volume
  docker run --rm -v /volume1/Docker/outline/storage:/mnt/storage alpine sh -c 'echo "nas_ok" > /mnt/storage/.probe'
  # Verify it appears on the host
  cat /volume1/Docker/outline/storage/.probe
  ```

## 9. ADM File Explorer Cache Quirks

The ADM File Explorer can serve stale views. If you create files/folders via SSH and they don't appear:

- Try collapsing and re-expanding the directory tree.
- If that fails, create a beacon file (`touch /volume1/Docker/outline/.refresh`) to force a re-index.

## 10. Do/Don't Quicklist

- ✅ **Do** use the LAN sshd (`ssh admin@<LAN-IP>`) for all host filesystem changes.
- ✅ **Do** disable root SSH login after use.
- ✅ **Do** keep the `admin` user in the `docker` group for convenience.
- ❌ **Don't** rely on Tailscale Web SSH for host volume changes until you have verified it is not sandboxed.
