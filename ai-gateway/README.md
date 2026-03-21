# AI Gateway (NVIDIA Build)

This service runs a LiteLLM gateway in front of NVIDIA Build (`integrate.api.nvidia.com`) and exposes a single OpenAI-compatible endpoint for local apps.

## Endpoint

- URL: `https://ai.homelabdev.space/v1`
- Auth: `Authorization: Bearer <LITELLM_MASTER_KEY>`

## Available model aliases

- `nvidia-fast` -> `meta/llama-3.1-8b-instruct`
- `nvidia-balanced` -> `meta/llama-3.1-70b-instruct`
- `nvidia-reasoning` -> `deepseek-ai/deepseek-v3.2`
- `nvidia-coder` -> `qwen/qwen3-coder-480b-a35b-instruct`
- `nvidia-embed` -> `nvidia/nv-embedqa-e5-v5`

## Quick test

```bash
curl -s https://ai.homelabdev.space/v1/chat/completions \
  -H "Authorization: Bearer <LITELLM_MASTER_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "nvidia-fast",
    "messages": [{"role": "user", "content": "Reply with: homelab-ok"}]
  }'
```

## For n8n HTTP Request node

- Method: `POST`
- URL: `https://ai.homelabdev.space/v1/chat/completions`
- Headers:
  - `Authorization: Bearer <LITELLM_MASTER_KEY>`
  - `Content-Type: application/json`
- JSON body:

```json
{
  "model": "nvidia-fast",
  "messages": [
    {"role": "system", "content": "You are a concise assistant."},
    {"role": "user", "content": "Summarize today's homelab status."}
  ]
}
```
