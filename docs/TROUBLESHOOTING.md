# Troubleshooting Guide

This guide provides solutions to common problems encountered with the Outline stack.

## Log Inspection

The first step in diagnosing any issue is to check the logs. Use the following Makefile command to tail the logs for all services:

```bash
make logs
```

This will show you the real-time output from the `outline`, `postgres`, and `redis` containers, which usually contains specific error messages.

---

### Symptom: `make up` fails or a service won't start

- **Symptom**: One or more containers exit immediately after `make up`. Running `make ps` shows a service as `Exited` or `Restarting`.
- **Likely Cause**:
  1.  **Missing or incorrect `.env` file**: The environment variables required by the services are not defined.
  2.  **Docker daemon not running**: The Docker engine on your machine is not active.
  3.  **Corrupted Docker volumes**: A previous unclean shutdown may have left the data volumes in a bad state.
- **Fix**:
  1.  Ensure you have a valid `.env` file (for local) or `.env.prod` file (for NAS) with all required keys. Start by copying the `.env.example` file.
  2.  Verify your Docker daemon is running.
  3.  As a last resort, bring the stack down (`make down`), manually delete the `./db`, `./storage`, and `./redis` directories (`sudo rm -rf ./db ./storage ./redis`), and then run `make up` again. **Warning**: This will delete all existing data.

---

### Symptom: Port conflict on `localhost:3000`

- **Symptom**: `make up` fails with an error message indicating that port `3000` is "already in use" or "already allocated".
- **Likely Cause**: Another application on your machine is already using port 3000.
- **Fix**:
  1.  Identify and stop the other process. You can find the process ID (PID) on macOS or Linux with:
      ```bash
      lsof -i :3000
      ```
  2.  Alternatively, you can change the host port mapping in the `docker-compose-outline.yml` file from `"3000:3000"` to something else, like `"3001:3000"`. If you do this, remember to access the application at the new port (e.g., `http://localhost:3001`).

---

### Symptom: Uploads are failing or images are not appearing

- **Symptom**: You can use the Outline UI, but uploading files or images results in an error.
- **Likely Cause**: There is a permissions issue with the shared uploads mount on the host machine. The Docker container (running as a non-root user) cannot write to the `./storage` directory.
- **Fix**:
  1.  Ensure the `./storage` directory exists in your project root.
  2.  Set the correct permissions to allow the container to write to it. The user ID (`uid`) inside the Outline container is `1000`. Run the following command from your project root:
      ```bash
      sudo chown -R 1000:1000 ./storage
      ```
  3.  Restart the Outline container to apply the changes: `make restart`.

---

### Symptom: `make health` or `make verify` fails

- **Symptom**: The health check fails with a non-2xx/3xx HTTP code, or the verification script reports an error.
- **Likely Cause**:
  1.  The `outline` container is not running or is in a crash loop.
  2.  The `DATABASE_URL` in your `.env` file is misconfigured.
  3.  A networking issue is preventing the `curl` command from reaching the container.
- **Fix**:
  1.  Check the service status with `make ps` and inspect the logs with `make logs` to see why the `outline` service might be failing.
  2.  Verify that your `.env` file contains the correct values for `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB`.
  3.  Ensure no firewall or proxy is blocking local network traffic on port 3000.

---

### Symptom: "I created folders in SSH but ADM doesn’t show them." (NAS)

- **Symptom**: You connect to the NAS via SSH, create directories (e.g., `/volume1/Docker/outline`), but they do not appear in the ADM File Explorer web UI.
- **Likely Cause**: You have connected to the **Tailscale Alpine sandbox**, not the host OS. Changes made in this sandboxed session are not reflected on the host filesystem.
- **Fix**:
  1.  Connect to the NAS using the **host sshd service** on its LAN IP: `ssh admin@<LAN-IP>`.
  2.  Re-create the directories on the host.
  3.  If ADM is still not showing the new folders, its cache may be stale. Force a refresh by creating a beacon file: `touch /volume1/Docker/.refresh_me`.
  4.  For more details, see the **[NAS SSH Access Guide](./NAS_SSH_ACCESS_GUIDE.md)**.

---

### Symptom: "tailscale: failed to look up local user..." (NAS)

- **Symptom**: When attempting to connect via `tailscale ssh`, the connection is rejected with an error related to user lookup.
- **Likely Cause**:
    1. The user you are trying to connect as (e.g., `admin`) does not exist on the host or is not permitted by your Tailscale ACLs.
    2. You are connecting to the sandboxed Tailscale environment which has a different set of users.
- **Fix**:
    1.  Verify the `ssh` section of your Tailscale ACLs correctly lists the `users` you want to allow.
    2.  When in doubt, bypass Tailscale SSH and use the host sshd service on the LAN IP.

---

### Symptom: "Permission denied to Docker socket" (NAS)

- **Symptom**: Running `docker` or `docker-compose` commands on the NAS fails with a permission error related to `/var/run/docker.sock`.
- **Likely Cause**: The `admin` user is not a member of the `docker` group and therefore cannot access the Docker daemon.
- **Fix**:
  1.  Add the `admin` user to the `docker` group.
      ```sh
      # Run this on the NAS host shell
      addgroup docker 2>/dev/null || true
      adduser admin docker 2>/dev/null || gpasswd -a admin docker
      ```
  2.  **Log out and log back in** for the new group membership to take effect.
