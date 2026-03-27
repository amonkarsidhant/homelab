from datetime import datetime, timezone

from fastapi import FastAPI

app = FastAPI(title="Nestra API", version="0.1.0")


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "service": "nestra-api"}


@app.get("/v1/status")
def status() -> dict:
    return {
        "name": "nestra-api",
        "version": "0.1.0",
        "environment": "production",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/v1/devices")
def devices() -> list[dict]:
    now = datetime.now(timezone.utc).isoformat()
    return [
        {
            "id": "dev-001",
            "name": "Living Room Thermostat",
            "type": "thermostat",
            "online": True,
            "last_seen": now,
        },
        {
            "id": "dev-002",
            "name": "Main Door Lock",
            "type": "lock",
            "online": True,
            "last_seen": now,
        },
    ]
