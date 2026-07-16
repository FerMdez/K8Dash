# ⎈ K8Dash

**🌐 Idioma:** Español · [English](README.en.md)

Dashboard web **moderno, rápido y ligero** para clusters de Kubernetes.
Una alternativa al *Kubernetes Dashboard* oficial con una interfaz mejorada, métricas en
tiempo real y un único binario sin dependencias externas, empaquetado en una imagen Docker
minúscula basada en `distroless`.

![Docker](https://img.shields.io/badge/Docker-fermdez96%2Fk8dash-2496ED?logo=docker&logoColor=white)
![License](https://shields.io/badge/license-CC--BY--NC--SA-green)

> [!NOTE]
> Este repositorio público contiene únicamente los **artefactos de distribución** de K8Dash: el binario ya compilado, el `Dockerfile` para construir la imagen, el manifiesto de despliegue de Kubernetes y esta documentación. El **código fuente** de la aplicación **no** se distribuye aquí. La imagen oficial se publica en Docker Hub como [`fermdez96/k8dash`](https://hub.docker.com/r/fermdez96/k8dash).

---

## ✨ Características

- **Resumen del cluster** con tarjetas de métricas (CPU/memoria reales vía `metrics-server`),
  estado de nodos, pods y conteo de todos los workloads.
- **Gráficas de tendencias en tiempo real**: un recolector en segundo plano acumula un
  histórico circular de CPU, memoria y pods, de modo que las gráficas muestran datos aunque
  nadie tenga el dashboard abierto al arrancar.
- **Visualización completa de recursos**: Nodos, Eventos, Pods, Deployments, StatefulSets,
  DaemonSets, ReplicaSets, Jobs, CronJobs, Services, Ingresses, Endpoints, Gateways y
  GatewayClasses (Gateway API), ConfigMaps, Secrets, PersistentVolumes, PVCs, StorageClasses,
  HorizontalPodAutoscalers, ServiceAccounts y releases de **Helm** v3.
- **Vistas de detalle enriquecidas** (drawer lateral) para la mayoría de recursos.
- **Advertencias contextuales**: los eventos de tipo *Warning* recientes se agrupan por
  objeto y se muestran como indicadores en las tablas de pods y workloads.
- **Acciones interactivas** completas: ver logs, escalar, reiniciar (rolling restart),
  eliminar, prune de ReplicaSets, suspender/disparar CronJobs, editar Secrets, rollback y
  desinstalación de releases de Helm, etc.
- **Port forwarding integrado** con proxy HTTP hacia el puerto reenviado.
- **Editor de manifiestos YAML en tiempo real** para cualquier recurso del cluster (incl. CRDs),
  con control de concurrencia optimista (`resourceVersion`).
- **Logs en tiempo real** vía WebSocket (por pod o agregados de un workload completo).
- **Terminal interactivo** (`kubectl exec`) contra el contenedor de cada pod.
- **Autenticación integrada opcional** (usuario/contraseña con PBKDF2 u OIDC/OAuth2),
  con protección contra fuerza bruta.
- **Tema claro/oscuro**, búsqueda/filtrado instantáneo, ordenación por columnas y
  auto-refresco. **PWA instalable** en escritorio y móvil.
- **Frontend embebido** en el binario: no hay que servir archivos aparte.
- **Imagen Docker minúscula** (~15 MB) basada en `distroless`, sin shell, ejecutada como
  usuario no-root.

---

## 🐳 Uso directo con Docker

La imagen se publica en Docker Hub: [`fermdez96/k8dash`](https://hub.docker.com/r/fermdez96/k8dash).

```bash
# Descargar la última versión
docker pull fermdez96/k8dash:latest

# Ejecutar montando tu kubeconfig
docker run --rm -p 8080:8080 \
  -v ${HOME}/.kube/config:/kube/config:ro \
  -e KUBECONFIG=/kube/config \
  fermdez96/k8dash:latest
```

Abre el navegador en **http://localhost:8080**.

> En Linux puede ser necesario `--network host` si tu API server es accesible vía
> `127.0.0.1` (p. ej. con `kind`/`minikube`).

### Fijar una versión concreta

Además de `latest`, cada release publica su tag semver:

```bash
docker pull fermdez96/k8dash:1.36.17
docker run --rm -p 8080:8080 \
  -v ${HOME}/.kube/config:/kube/config:ro \
  -e KUBECONFIG=/kube/config \
  fermdez96/k8dash:1.36.17
```

### Variables de entorno

| Variable      | Por defecto | Descripción                                            |
|---------------|-------------|--------------------------------------------------------|
| `KUBECONFIG`  | —           | Ruta(s) al kubeconfig. Admite varias separadas por `:` (Linux). |
| `K8DASH_ADDR` | `:8080`     | Dirección y puerto de escucha del servidor HTTP.       |
| `K8DASH_NAMESPACE` | *(autodetectado)* | Namespace donde persistir el Secret `k8dash-auth` de la autenticación. In-cluster se detecta del ServiceAccount. |
| `K8DASH_AUTH_DISABLED` | `false` | Si es `true`/`1`, **desactiva la autenticación** ignorando la configuración persistida. Mecanismo de recuperación si el admin queda bloqueado. |

---

## 🔨 Reconstruir la imagen desde este repositorio

Este repositorio incluye un [`Dockerfile`](Dockerfile) que construye la imagen a partir
del **binario precompilado** que se distribuye junto a él, sin necesidad de tener el
código fuente. Se publican tres binarios: `k8dash` (genérico), `k8dash-amd64` y
`k8dash-arm64`.

```bash
git clone https://github.com/FerMdez/K8Dash.git
cd K8Dash

# Imagen con el binario genérico
docker build -t k8dash:local .

# O para una arquitectura concreta (selecciona el binario correspondiente)
docker build --build-arg BIN=k8dash-amd64 -t k8dash:amd64 .
docker build --build-arg BIN=k8dash-arm64 -t k8dash:arm64 .
```

> La imagen oficial en Docker Hub (`fermdez96/k8dash`) es **multi-arch**
> (`linux/amd64` + `linux/arm64`): `docker pull` selecciona la arquitectura del host.

---

## ☸️ Despliegue dentro del cluster

El manifiesto [`deploy/kubernetes.yaml`](deploy/kubernetes.yaml) crea un `Namespace`,
`ServiceAccount`, `ClusterRole`/`ClusterRoleBinding` con los permisos mínimos, un
`Deployment` endurecido (rootless, read-only FS, sin capabilities), un `Service` y un
`Ingress` de ejemplo.

La imagen que utiliza el manifiesto es `fermdez96/k8dash:latest`.

```bash
# 1. Aplica los manifiestos
kubectl apply -f deploy/kubernetes.yaml

# 2. Accede mediante port-forward
kubectl -n k8dash port-forward svc/k8dash 8080:80
```

Abre el navegador en **http://localhost:8080**.

Cuando se ejecuta dentro del cluster, K8Dash usa automáticamente el `ServiceAccount`
montado: **no necesita `KUBECONFIG`**.

### Fijar una versión concreta en el despliegue

El manifiesto usa `fermdez96/k8dash:latest`. Para desplegar una versión concreta, edita
la línea `image:` del `Deployment` o aplica un *patch*:

```bash
kubectl -n k8dash set image deployment/k8dash k8dash=fermdez96/k8dash:1.36.17
```

### Exposición con Ingress (opcional)

El manifiesto incluye un `Ingress` de ejemplo (comentado para el host
`dashboard.example.com`) preparado para **ingress-nginx** con los timeouts y cabeceras
necesarios para el streaming de logs/eventos y el terminal interactivo (WebSockets).
Ajusta el `host`, el `secretName` de TLS y, si usas otro controlador (p. ej. Traefik),
adapta las anotaciones.

> [!IMPORTANT]
> El streaming de logs/eventos y el terminal interactivo usan WebSockets (rutas `/api/ws/...`). Si el proxy/Ingress no propaga el *Upgrade* o cierra conexiones ociosas, verás en el navegador *"WebSocket connection failed"*.

---

## 🔒 Seguridad

- K8Dash hereda **exactamente los permisos** del kubeconfig o ServiceAccount con el que
  se ejecuta. Limita el RBAC para entornos sensibles.
- El manifiesto incluido aplica el **principio de mínimo privilegio** y un contenedor
  endurecido (no root, FS de solo lectura, sin capabilities).
- En el **listado** de Secrets solo se muestran metadatos; sus valores solo se exponen
  bajo demanda al abrir/editar un Secret concreto.
- Funcionalidades como **port-forward**, **terminal exec** y las acciones de **Helm**
  (rollback/desinstalación) permiten interactuar directamente con las cargas de trabajo:
  concédelas solo a operadores de confianza.
- No expongas el dashboard directamente a Internet sin una capa de autenticación.

---

## 📝 Changelog

Consulta [`CHANGELOG.md`](CHANGELOG.md) para el histórico de cambios de cada versión.

---

## 📝 Licencia

Creative Commons Attribution-NonCommercial-ShareAlike (CC BY-NC-SA).

---

## ©️ Autor

[`Fernando Méndez Torrubiano`](https://fermdez.net/)
