# Dev & Prod Handbook (Scene 1)

This handbook is the practical guide for developers working on the Outline stack. It covers local setup, production environment details, and the tools that govern the development workflow.

## Local Quickstart

Your local machine is your primary development environment. The goal is to mirror the production setup as closely as possible.

1.  **Bootstrap Environment**:
    *   Clone the repository to `~/infra-projects/outline`.
    *   Copy the example environment file: `cp .env.example .env`.
    *   Update `.env` with any necessary local secrets (the defaults are fine for initial startup).

2.  **Start the Stack**:
    *   Bring all services up in the background:
        ```bash
        make up
        ```

3.  **Verify Health**:
    *   Check that the Outline web application is responsive:
        ```bash
        make health
        ```
        You should see an "OK" status. You can now access the app at `http://localhost:3000`.
    *   Run the full verification script to check for configuration drift and other common issues:
        ```bash
        make verify
        ```

## Production Pointers

The production environment lives on the NAS. All detailed setup steps are in the canonical `SCENE_1_SQUARE_ONE_Outline_NAS_Project.md` document.

*   **Repo Path**: `/volume1/Docker/outline`
*   **Environment File**: `/volume1/Docker/outline/.env.prod` (This file must be created manually on the NAS and should never be committed to the repository).

## Makefile Reference

The `Makefile` provides convenient shortcuts for common operations.

| Target      | Description                                                 |
| :---------- | :---------------------------------------------------------- |
| `up`        | Start the full Docker Compose stack in detached mode.       |
| `down`      | Stop and remove all containers defined in the Compose file. |
| `ps`        | Show the status of the running services.                    |
| `logs`      | Tail the logs from all running services.                    |
| `restart`   | Restart the `outline` web application service only.         |
| `health`    | Perform a quick HTTP health check on the web app.           |
| `verify`    | Run the comprehensive local verification script.            |

## CI Gates

To maintain code quality and a clean Git history, all pull requests are subject to the following automated checks:

*   **Commitlint**: Enforces [Conventional Commit](https://www.conventionalcommits.org/) message formatting. Use `pnpm commit` for an interactive guide.
*   **Semantic PR Title**: The pull request title must also follow conventional commit standards.
*   **CI Workflow**: A GitHub Action runs on every PR to lint and format the code.
*   **Jules Checks on PR head SHA**: A specialized check run by the Jules agent to ensure project standards are met before merging.

## Environment Keys (Scene 1)

The stack requires a minimal set of environment variables to function. These must be defined in `.env` for local development and `.env.prod` for production.

| Key                 | Example Value        | Description                                     |
| :------------------ | :------------------- | :---------------------------------------------- |
| `POSTGRES_USER`     | `outline`            | The username for the PostgreSQL database.       |
| `POSTGRES_PASSWORD` | `(a secure password)`  | The password for the PostgreSQL user.         |
| `POSTGRES_DB`       | `outline`            | The name of the PostgreSQL database to use.     |
| `PGSSLMODE`         | `disable`            | SSL mode for the database connection (disabled for local). |
| `DATABASE_URL`      | `(generated)`        | The full connection string used by Outline (auto-generated from other keys). |