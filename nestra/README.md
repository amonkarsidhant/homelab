# Nestra Home OS SaaS Bootstrap

This directory contains the first deployable Nestra SaaS stack.

## Services
- `nestra-web` -> `https://nestra.homelabdev.space`
- `nestra-api` -> `https://api.nestra.homelabdev.space`
- `nestra-auth` -> `https://auth.nestra.homelabdev.space`

## Quick start
1. Copy `.env.example` to `.env` and set `AUTH_JWT_SECRET`.
2. Ensure DNS A records for all three hosts point to Traefik VM IP.
3. Start stack:

```bash
docker compose -f nestra/docker-compose.yml --env-file nestra/.env up -d --build
```

## Verification
```bash
curl -sS https://api.nestra.homelabdev.space/health
curl -sS https://auth.nestra.homelabdev.space/health
```
