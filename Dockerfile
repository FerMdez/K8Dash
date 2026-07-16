# ===============================================================================
# Dockerfile del repositorio PÚBLICO de K8Dash
# ===============================================================================
#
# El binario se genera con:
#     CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -trimpath -o k8dash .
# lo que produce un ejecutable estático (sin dependencias de libc) apto para
# imágenes distroless/scratch.
#
# Construir localmente (usa el binario genérico "k8dash"):
#     docker build -t fermdez96/k8dash:latest .
#
# Construir para una arquitectura concreta (usando el binario por arquitectura
# que acompaña a este repositorio, p. ej. en un build multi-arch):
#     docker build --build-arg BIN=k8dash-amd64 -t k8dash:amd64 .
#     docker build --build-arg BIN=k8dash-arm64 -t k8dash:arm64 .
# ===============================================================================

# Imagen final mínima (sin shell, sin gestor de paquetes, usuario no-root).
FROM gcr.io/distroless/static-debian13:nonroot

# Nombre del binario a incluir. Por defecto el genérico "k8dash"; en el build
# multi-arch de la pipeline se pasa k8dash-amd64 / k8dash-arm64.
ARG BIN=k8dash

# Metadatos OCI estándar.
LABEL org.opencontainers.image.title="K8Dash" \
      org.opencontainers.image.description="Dashboard web moderno, rápido y ligero para clusters de Kubernetes." \
      org.opencontainers.image.source="https://github.com/FerMdez/K8Dash" \
      org.opencontainers.image.url="https://github.com/FerMdez/K8Dash" \
      org.opencontainers.image.vendor="Fernando Méndez Torrubiano" \
      org.opencontainers.image.licenses="CC BY-NC-SA"

# Certificados raíz para poder establecer conexiones TLS con el API server.
# La imagen distroless:static ya incluye /etc/ssl/certs/ca-certificates.crt.

# Copiamos el binario estático precompilado que acompaña a este repositorio.
# Se selecciona mediante el ARG BIN (genérico por defecto, o por arquitectura).
COPY ${BIN} /k8dash

# Ejecutamos como usuario sin privilegios (UID/GID numérico "nonroot" = 65532).
# Kubernetes con runAsNonRoot exige un UID numérico para verificar que no es root.
USER 65532:65532

EXPOSE 8080

ENV K8DASH_ADDR=":8080"

ENTRYPOINT ["/k8dash"]
