# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Stage 2: Build Dart backend
FROM dart:stable AS backend-build
WORKDIR /app
COPY backend/pubspec.yaml backend/pubspec.lock* ./
RUN dart pub get
COPY backend/ .
RUN dart compile exe bin/server.dart -o bin/server

# Stage 3: Production image
FROM scratch
COPY --from=backend-build /runtime/ /
COPY --from=backend-build /app/bin/server /app/bin/server
COPY --from=flutter-build /app/build/web/ /app/public/
EXPOSE 8080
CMD ["/app/bin/server"]
