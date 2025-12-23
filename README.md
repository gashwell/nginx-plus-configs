# Nginx Plus Configurations

Production-ready Nginx Plus configurations for AI Gateway.

## Structure

```
conf.d/      - HTTP configurations
njs/         - NJS modules (linked from njs-modules repo)
ssl/         - SSL certificates (not in git)
templates/   - Configuration templates
```

## macOS Setup Instructions

### Prerequisites

1. **Docker Desktop for Mac**
   ```bash
   brew install --cask docker
   ```

2. **Nginx Plus License** (required)
   - Obtain `nginx-repo.crt` and `nginx-repo.key` from F5
   - Place them in this directory (they're gitignored)

3. **SSL Certificates**
   ```bash
   # Generate self-signed certs for local development
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout ssl/cert.key \
     -out ssl/cert.crt \
     -subj "/CN=gateway.local"
   ```

### Link NJS Modules

```bash
# From this directory, link the njs-modules repo
ln -sf ../njs-modules/src/* njs/
```

### Build Docker Image

```bash
# Build the Nginx Plus image
docker build -t nginx-ai-gateway .
```

### Run Locally

```bash
# Run with mounted config for development
docker run -d --name ai-gateway \
  -p 443:443 \
  -p 8080:8080 \
  -v "$(pwd)/conf.d:/etc/nginx/conf.d:ro" \
  -v "$(pwd)/njs:/etc/nginx/njs:ro" \
  nginx-ai-gateway

# View logs
docker logs -f ai-gateway

# Stop
docker stop ai-gateway && docker rm ai-gateway
```

### Test Configuration

```bash
# Validate nginx config
docker run --rm \
  -v "$(pwd)/conf.d:/etc/nginx/conf.d:ro" \
  nginx-ai-gateway nginx -t

# Test health endpoint
curl -k https://localhost/health

# Test Nginx Plus API
curl http://localhost:8080/api/
```

### Add to /etc/hosts (macOS)

```bash
echo "127.0.0.1 gateway.local" | sudo tee -a /etc/hosts
```

## Configuration Files

| File | Description |
|------|-------------|
| `api-gateway.conf` | Main AI gateway configuration with routing |

## Features

- **Keyval Zones**: Dynamic API key storage and model routing
- **Rate Limiting**: 100 requests/minute per API key with burst support
- **NJS Integration**: Intelligent request routing via JavaScript
- **Upstreams**: OpenAI, Anthropic, and Ollama (local) support
- **Health Checks**: Built-in health endpoint
- **Nginx Plus API**: Management API on port 8080

## Environment Variables

The container uses these paths:
- `/etc/nginx/conf.d/` - Configuration files
- `/etc/nginx/njs/` - NJS modules
- `/etc/nginx/ssl/` - SSL certificates
- `/var/lib/nginx/state/` - Keyval persistence
