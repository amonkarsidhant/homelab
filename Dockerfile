FROM alpine:latest

WORKDIR /app

COPY . .

RUN echo "Build complete"

CMD ["echo", "Hello from homelab app!"]

EXPOSE 8080

