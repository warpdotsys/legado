#!/bin/sh

# Start Nginx in background
echo "Starting Nginx web server..."
nginx

# Start Legado JVM Backend in foreground
echo "Starting Legado JVM Backend..."
exec ./gradlew :app:testDebugUnitTest --tests "io.legado.app.ServerRunner" --no-daemon
