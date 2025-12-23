# Nginx Plus with NJS Module
# Requires nginx-repo.crt and nginx-repo.key from F5

FROM debian:bullseye-slim

LABEL maintainer="AI Gateway Team"
LABEL description="Nginx Plus with NJS for AI Gateway"

# Install prerequisites
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Copy Nginx Plus license files
COPY nginx-repo.crt /etc/ssl/nginx/
COPY nginx-repo.key /etc/ssl/nginx/

# Add Nginx Plus repository
RUN curl -fsSL https://cs.nginx.com/static/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
    https://pkgs.nginx.com/plus/debian $(lsb_release -cs) nginx-plus" \
    > /etc/apt/sources.list.d/nginx-plus.list \
    && echo "Acquire::https::pkgs.nginx.com::Verify-Peer \"true\";" > /etc/apt/apt.conf.d/90nginx \
    && echo "Acquire::https::pkgs.nginx.com::Verify-Host \"true\";" >> /etc/apt/apt.conf.d/90nginx \
    && echo "Acquire::https::pkgs.nginx.com::SslCert \"/etc/ssl/nginx/nginx-repo.crt\";" >> /etc/apt/apt.conf.d/90nginx \
    && echo "Acquire::https::pkgs.nginx.com::SslKey \"/etc/ssl/nginx/nginx-repo.key\";" >> /etc/apt/apt.conf.d/90nginx

# Install Nginx Plus and NJS module
RUN apt-get update && apt-get install -y \
    nginx-plus \
    nginx-plus-module-njs \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /etc/ssl/nginx

# Create state directory for keyval persistence
RUN mkdir -p /var/lib/nginx/state && \
    chown -R nginx:nginx /var/lib/nginx/state

# Create NJS directory
RUN mkdir -p /etc/nginx/njs

# Load NJS module in main config
RUN sed -i '1i load_module modules/ngx_http_js_module.so;' /etc/nginx/nginx.conf

# Copy configuration files
COPY conf.d/ /etc/nginx/conf.d/
COPY njs/ /etc/nginx/njs/
COPY ssl/ /etc/nginx/ssl/

# Expose ports
EXPOSE 443 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/api/ || exit 1

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
