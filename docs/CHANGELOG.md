# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v1.0.0-scene1] - 2025-10-03

This is the initial release, marking the completion of Scene 1: Foundations.

### Added

*   Docker Compose stack for `outline`, `postgres`, and `redis`.
*   `Makefile` with helper targets for `up`, `down`, `logs`, `health`, and `verify`.
*   CI gates enforcing Conventional Commits and Semantic PR titles.
*   Jules Checks integration on pull request head SHA for quality assurance.
*   Persistent storage volume for file uploads (`./storage`).

### Changed

*   Established a formal dev-to-prod workflow (local dev, NAS prod).
*   Finalized the environment variable model with `.env.example` and `.env.prod.example`.

### Docs

*   Created `SCENE_1_RELEASE_NOTES.md` to summarize the release.
*   Added `ARCHITECTURE_OVERVIEW.md` with a system diagram.
*   Published `DEV_PROD_HANDBOOK.md` for developers.
*   Wrote a `TROUBLESHOOTING.md` guide for common issues.
*   Initialized this `CHANGELOG.md` and the `SCENE_LEDGER.md`.