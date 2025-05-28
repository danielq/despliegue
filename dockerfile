# Etapa de construcción
FROM ghcr.io/flutter/flutter:stable as build

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

# Etapa de producción
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]