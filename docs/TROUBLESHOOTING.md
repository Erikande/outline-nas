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

*   **Symptom**: One or more containers exit immediately after `make up`. Running `make ps` shows a service as `Exited` or `Restarting`.
*   **Likely Cause**:
    1.  **Missing or incorrect `.env` file**: The environment variables required by the services are not defined.
    2.  **Docker daemon not running**: The Docker engine on your machine is not active.
    3.  **Corrupted Docker volumes**: A previous unclean shutdown may have left the data volumes in a bad state.
*   **Fix**:
    1.  Ensure you have a valid `.env` file (for local) or `.env.prod` file (for NAS) with all required keys. Start by copying the `.env.example` file.
    2.  Verify your Docker daemon is running.
    3.  As a last resort, bring the stack down (`make down`), manually delete the `./db`, `./storage`, and `./redis` directories (`sudo rm -rf ./db ./storage ./redis`), and then run `make up` again. **Warning**: This will delete all existing data.

---

### Symptom: Port conflict on `localhost:3000`

*   **Symptom**: `make up` fails with an error message indicating that port `3000` is "already in use" or "already allocated".
*   **Likely Cause**: Another application on your machine is already using port 3000.
*   **Fix**:
    1.  Identify and stop the other process. You can find the process ID (PID) on macOS or Linux with:
        ```bash
        lsof -i :3000
        ```
    2.  Alternatively, you can change the host port mapping in the `docker-compose-outline.yml` file from `"3000:3000"` to something else, like `"3001:3000"`. If you do this, remember to access the application at the new port (e.g., `http://localhost:3001`).

---

### Symptom: Uploads are failing or images are not appearing

*   **Symptom**: You can use the Outline UI, but uploading files or images results in an error.
*   **Likely Cause**: There is a permissions issue with the shared uploads mount on the host machine. The Docker container (running as a non-root user) cannot write to the `./storage` directory.
*   **Fix**:
    1.  Ensure the `./storage` directory exists in your project root.
    2.  Set the correct permissions to allow the container to write to it. The user ID (`uid`) inside the Outline container is `1000`. Run the following command from your project root:
        ```bash
        sudo chown -R 1000:1000 ./storage
        ```
    3.  Restart the Outline container to apply the changes: `make restart`.

---

### Symptom: `make health` or `make verify` fails

*   **Symptom**: The health check fails with a non-2xx/3xx HTTP code, or the verification script reports an error.
*   **Likely Cause**:
    1.  The `outline` container is not running or is in a crash loop.
    2.  The `DATABASE_URL` in your `.env` file is misconfigured.
    3.  A networking issue is preventing the `curl` command from reaching the container.
*   **Fix**:
    1.  Check the service status with `make ps` and inspect the logs with `make logs` to see why the `outline` service might be failing.
    2.  Verify that your `.env` file contains the correct values for `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB`.
    3.  Ensure no firewall or proxy is blocking local network traffic on port 3000.