# Build Stage for Vue Web UI
FROM node:20-alpine AS build

# Install pnpm
RUN npm install -g pnpm@9

WORKDIR /app/modules/web

# Copy package.json first to leverage Docker cache
COPY modules/web/package.json ./

# Install dependencies
RUN pnpm install

# Copy source code and build Vue app
COPY modules/web/ ./
RUN pnpm run build

# Production Stage
FROM nginx:alpine

# Copy nginx config template (will be processed by envsubst to conf.d/default.conf at runtime)
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Copy built Vue Web UI assets directly to Nginx static root for full-screen UI
COPY --from=build /app/modules/web/dist /usr/share/nginx/html

# Copy fallback error page
COPY proxy_error.html /usr/share/nginx/html/proxy_error.html

EXPOSE 4080 4081 4082

CMD ["nginx", "-g", "daemon off;"]
