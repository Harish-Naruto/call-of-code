# Docker — Local Development Guide

This document explains how to spin up the full **Call of Code** local development environment using Docker Compose.

The stack consists of two services running on a shared Docker network (`coc-local`):

| Service     | Image / Source                          | Port   |
| ----------- | --------------------------------------- | ------ |
| `coc-api`   | `callofcode07/coc-api:latest` (Docker Hub) | 3000   |
| `frontend`  | Built locally from this repo (`Dockerfile`) | 3001   |

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) ≥ 24 **or** Docker Engine + Docker Compose plugin ≥ 2.22
- Git

---

## Quick Start

### 1. Configure environment variables

The Compose setup reads env files from the `docker/` directory. Copy the example files and fill in your values:

```bash
# COC API service
cp docker/.env.local.coc-api.example docker/.env.local.coc-api

# Frontend service
cp docker/.env.local.frontend.example docker/.env.local.frontend
```

> **Never commit** the real `docker/.env.local.*` files — they are already listed in `.gitignore`.

### 2. Start the services

```bash
docker compose up --build
```

| Flag        | Effect                                            |
| ----------- | ------------------------------------------------- |
| `--build`   | (Re)build the frontend image before starting      |
| `--watch`   | Enable hot-reload — see [Hot Reload](#hot-reload) |
| `-d`        | Run in the background (detached mode)             |

The frontend will be available at **http://localhost:3001** once the `coc-api` health check passes.

---

## Environment Variables

### `docker/.env.local.coc-api`

Consumed by the `coc-api` container. Credentials for the Supabase / Postgres backend.

| Variable                  | Description                                               |
| ------------------------- | --------------------------------------------------------- |
| `DATABASE_URL`            | Postgres pooler connection string (used at runtime)       |
| `DIRECT_URL`              | Postgres direct connection string (used for migrations)   |
| `SUPABASE_URL`            | Your Supabase project URL                                 |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service-role JWT (keep this secret!)           |
| `NODE_ENV`                | Set to `development` for local use                        |

Example:
```dotenv
DATABASE_URL=postgresql://postgres.<ref>:<password>@aws-0-ap-south-1.pooler.supabase.com:5432/postgres
DIRECT_URL=postgresql://postgres.<ref>:<password>@aws-0-ap-south-1.pooler.supabase.com:5432/postgres
SUPABASE_URL=https://<ref>.supabase.co
SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
NODE_ENV=development
```

---

### `docker/.env.local.frontend`

Consumed by the `frontend` container at runtime.

| Variable       | Description                                         |
| -------------- | --------------------------------------------------- |
| `API_BASE_URL` | URL the frontend uses to reach the API. Within the Docker network this is `http://coc-api:3000` |
| `GITHUB_TOKEN` | GitHub personal access token (optional, for contribution graphs) |

Example:
```dotenv
API_BASE_URL=http://coc-api:3000
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

---

## Hot Reload

The Compose file uses Docker's `develop.watch` feature to sync source files into the running container **without a full rebuild**.

Start with watch mode enabled:

```bash
docker compose up --watch
```

Synced paths:

| Local path     | Container path    | Action  |
| -------------- | ----------------- | ------- |
| `./app`        | `/app/app`        | `sync`  |
| `./components` | `/app/components` | `sync`  |
| `./lib`        | `/app/lib`        | `sync`  |
| `./public`     | `/app/public`     | `sync`  |
| `package.json` / `package-lock.json` | — | `rebuild` (triggers a full image rebuild) |

> **Note:** `sync` changes are reflected instantly. Dependency changes (`package.json`) trigger a full rebuild automatically.

---

## Dockerfile Stages

The multi-stage `Dockerfile` has three stages:

| Stage     | Base Image        | Purpose                                          |
| --------- | ----------------- | ------------------------------------------------ |
| `deps`    | `node:20-alpine`  | Install `node_modules` with `npm ci`             |
| `builder` | `node:20-alpine`  | Copy deps + source, run `npm run build`. **Used by Compose in dev** (keeps dev deps intact). |
| `runner`  | `node:20-alpine`  | Lean production image — only production artefacts |

The Compose file targets the `builder` stage so that dev dependencies (like TypeScript types) remain available inside the container.

---

## Useful Commands

```bash
# Start all services (foreground)
docker compose up --build

# Start with hot-reload
docker compose up --build --watch

# Start in background
docker compose up -d --build

# View logs for a specific service
docker compose logs -f frontend
docker compose logs -f coc-api

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v

# Rebuild only the frontend image
docker compose build frontend

# Open a shell inside the frontend container
docker compose exec frontend sh

# Check service health
docker compose ps
```

---

## Service Health Check

The `coc-api` container exposes a health endpoint at `GET /health`. Docker polls it every **15 seconds** (3 retries, 5 s timeout, 15 s start period). The `frontend` service will not start until `coc-api` is reported **healthy**.

```yaml
healthcheck:
  test: ["CMD", "wget", "-qO-", "http://localhost:3000/health"]
  interval: 15s
  timeout: 5s
  retries: 3
  start_period: 15s
```

---

## Troubleshooting

### Frontend can't reach the API

- Confirm `docker/.env.local.frontend` has `API_BASE_URL=http://coc-api:3000`.
- Check that `coc-api` is healthy: `docker compose ps`.
- Inspect API logs: `docker compose logs coc-api`.

### Port already in use

Change the host-side port mapping in `docker-compose.yml`:
```yaml
ports:
  - "3002:3001"   # map host 3002 → container 3001
```

### Hot-reload not working

Ensure you started with `--watch`: `docker compose up --watch`. The feature requires Docker Compose ≥ 2.22.

### Pulling a fresh copy of the API image

```bash
docker compose pull coc-api
docker compose up --build
```
