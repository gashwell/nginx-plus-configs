# Nginx Plus Configurations

Production-ready Nginx Plus configurations for AI Gateway.

## Structure

```
conf.d/      - HTTP configurations
njs/         - NJS modules (linked from njs-modules repo)
ssl/         - SSL certificates (not in git)
templates/   - Configuration templates
```

## macOS Development

These configs run in Docker containers.

```bash
# Test configuration
docker run --rm -v "$(pwd)/conf.d:/etc/nginx/conf.d:ro" \
  nginx:latest nginx -t
```

## Symlink NJS modules (macOS)

```bash
# Link njs-modules to this repo
ln -s ../njs-modules/src njs
```

## Files

- `api-gateway.conf` - Main AI gateway configuration
- `upstreams.conf` - AI model upstream definitions
- `security.conf` - Security headers and settings
