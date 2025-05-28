# Usa Alpine Linux que es más ligero y suele tener menos problemas
FROM alpine:latest

# Instala dependencias mínimas
RUN apk add --no-cache \
    bash \
    curl \
    git \
    unzip \
    xz \
    zip

# Instala Flutter manualmente
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="$PATH:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"
RUN flutter doctor -v

WORKDIR /app
COPY . .
RUN flutter pub get && flutter build web --release

# Fase de producción
FROM nginx
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]