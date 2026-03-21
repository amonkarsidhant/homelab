# LiteLLM Chat UI (Open WebUI)

This service provides a ChatGPT-like interface for users to chat with models served by LiteLLM.

## URL

- https://chat.homelabdev.space

## Backend

- Open WebUI -> LiteLLM proxy (`http://litellm:4000/v1`)
- Default model: `nvidia-fast`

## Auth

- Protected by Authelia via Traefik middleware
- Open WebUI internal auth is disabled (`WEBUI_AUTH=False`) so SSO is the only gate

## Operations

From this folder:

- Start: `docker-compose up -d`
- Restart: `docker-compose restart`
- Logs: `docker logs open-webui --tail 200`
