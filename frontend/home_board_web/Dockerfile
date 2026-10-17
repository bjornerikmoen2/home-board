# Build stage
FROM debian:trixie AS build-env

# Flutter is pinned to the release that matches the code generators in pubspec.lock
# (build_runner, freezed, riverpod_generator, analyzer 7.6 = Dart 3.9). With a newer Dart the
# analyzer can't parse the Flutter SDK's code and build_runner hangs, so upgrade Flutter and
# those packages together.
ARG FLUTTER_VERSION=3.35.7

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl git wget unzip gdb libstdc++6 \
    libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 && \
    apt-get clean

# Install Flutter: only the pinned release, without its git history
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable web and download the web SDK
RUN flutter config --enable-web && \
    flutter precache --web

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

# Generate code (freezed, json_serializable, etc.)
RUN dart run build_runner build --delete-conflicting-outputs

# Enable web for the project
RUN flutter create . --platforms web

# Build the web app
RUN flutter build web --release

# Runtime stage - use nginx to serve the static files
FROM nginx:alpine

# Copy the built web app to nginx html directory
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration as template
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose port 80
EXPOSE 80

# Start nginx with environment variable substitution
ENTRYPOINT ["/docker-entrypoint.sh"]
