# --- Stage 1: Build Vue Web UI ---
FROM node:20-alpine AS build-ui

# Install pnpm
RUN npm install -g pnpm@9

WORKDIR /app/modules/web

# Copy package.json to leverage Docker cache
COPY modules/web/package.json ./
RUN pnpm install

# Copy source code and build Vue app
COPY modules/web/ ./
RUN pnpm run build

# --- Stage 2: JVM Backend & Nginx Web Server ---
FROM eclipse-temurin:17-jdk-alpine

# Install Nginx and other requirements
RUN apk add --no-cache nginx bash git

WORKDIR /app

# Copy built Vue Web UI assets to Nginx static root
COPY --from=build-ui /app/modules/web/dist /usr/share/nginx/html
COPY proxy_error.html /usr/share/nginx/html/proxy_error.html

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/http.d/default.conf

# Copy all source files
COPY . .

# Warm up Gradle cache (download Gradle distribution)
RUN ./gradlew --version --no-daemon

# Run test compile to download all compiler, JVM, and Robolectric dependencies during image build
RUN ./gradlew :app:compileDebugUnitTestSources --no-daemon

# Make entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Expose ports
# 4080: Vue Web UI (Full screen)
# 4081: Legado Web API (Mapped to Port 1122 backend)
# 4082: WebSocket Proxy (Mapped to Port 1123 backend)
EXPOSE 4080 4081 4082

# Define storage directory for Room database persistence
VOLUME ["/storage"]

ENTRYPOINT ["/app/entrypoint.sh"]
