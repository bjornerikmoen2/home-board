# Build stage
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl git wget unzip gdb libstdc++6 \
    libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 && \
    apt-get clean

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Set Flutter channel to stable and enable web
RUN flutter channel stable && \
    flutter upgrade && \
    flutter config --enable-web

# Create app directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy the entire app
COPY . .

# Generate localization files
RUN flutter gen-l10n

# Enable web for the project
RUN flutter create . --platforms web

# Build the web app
RUN flutter build web --release

# Runtime stage - use nginx to serve the static files
FROM nginx:alpine

# Copy the built web app to nginx html directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
