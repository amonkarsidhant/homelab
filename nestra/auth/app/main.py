import os
from datetime import datetime, timezone

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Nestra Auth", version="0.1.0")


class LoginRequest(BaseModel):
    username: str
    password: str


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "service": "nestra-auth"}


@app.get("/.well-known/openid-configuration")
def oidc_discovery() -> dict:
    issuer = os.getenv("AUTH_ISSUER", "https://auth.nestra.homelabdev.space")
    return {
        "issuer": issuer,
        "authorization_endpoint": f"{issuer}/authorize",
        "token_endpoint": f"{issuer}/token",
        "userinfo_endpoint": f"{issuer}/userinfo",
        "jwks_uri": f"{issuer}/jwks.json",
        "response_types_supported": ["code"],
        "grant_types_supported": ["authorization_code", "refresh_token"],
        "subject_types_supported": ["public"],
        "id_token_signing_alg_values_supported": ["RS256"],
    }


@app.post("/v1/login")
def login(_payload: LoginRequest) -> dict:
    return {
        "status": "not-implemented",
        "message": "Authentication flow will be implemented in Sprint 2.",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
