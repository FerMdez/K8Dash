# ⎈ K8Dash

**🌐 Language:** English · [Español](README.md)

A **modern, fast and lightweight** web dashboard for Kubernetes clusters.
An alternative to the official *Kubernetes Dashboard* with an improved interface, real-time
metrics and a single binary with no external dependencies, packaged in a tiny Docker image
based on `distroless`.

![Docker](https://img.shields.io/badge/Docker-fermdez96%2Fk8dash-2496ED?logo=docker&logoColor=white)
![License](https://shields.io/badge/license-CC--BY--NC--SA-green)

> [!NOTE]
> This public repository contains only the **distribution artifacts** of K8Dash: the precompiled binary, the `Dockerfile` to build the image, the Kubernetes deployment manifest and this documentation. The application's **source code** is **not** distributed here. The official image is published on Docker Hub as [`fermdez96/k8dash`](https://hub.docker.com/r/fermdez96/k8dash).

---

## ✨ Features

- **Cluster overview** with metric cards (real CPU/memory via `metrics-server`),
  node status, pods and counts of all workloads.
- **Real-time trend charts**: a background collector accumulates a circular history of CPU,
  memory and pods, so the charts show data even if no one had the dashboard open at startup.
- **Full resource visualization**: Nodes, Events, Pods, Deployments, StatefulSets,
  DaemonSets, ReplicaSets, Jobs, CronJobs, Services, Ingresses, Endpoints, Gateways and
  GatewayClasses (Gateway API), ConfigMaps, Secrets, PersistentVolumes, PVCs, StorageClasses,
  HorizontalPodAutoscalers, ServiceAccounts and **Helm** v3 releases.
- **Rich detail views** (side drawer) for most resources.
- **Contextual warnings**: recent *Warning* events are grouped by object and shown as
  indicators in the pod and workload tables.
- **Full interactive actions**: view logs, scale, restart (rolling restart), delete, prune
  ReplicaSets, suspend/trigger CronJobs, edit Secrets, rollback and uninstall Helm releases,
  and more.
- **Built-in port forwarding** with an HTTP proxy to the forwarded port.
- **Live YAML manifest editor** for any cluster resource (including CRDs), with optimistic
  concurrency control (`resourceVersion`).
- **Real-time logs** over WebSocket (per pod or aggregated for a full workload).
- **Interactive terminal** (`kubectl exec`) against each pod's container.
- **Optional built-in authentication** (username/password with PBKDF2 or OIDC/OAuth2),
  with brute-force protection.
- **Light/dark theme**, instant search/filtering, column sorting and auto-refresh.
  **Installable PWA** on desktop and mobile.
- **Embedded frontend** in the binary: no need to serve files separately.
- **Tiny Docker image** (~15 MB) based on `distroless`, without a shell, running as a
  non-root user.

---

## 🐳 Direct usage with Docker

The image is published on Docker Hub: [`fermdez96/k8dash`](https://hub.docker.com/r/fermdez96/k8dash).

```bash
# Pull the latest version
docker pull fermdez96/k8dash:latest

# Run mounting your kubeconfig
docker run --rm -p 8080:8080 \
  -v ${HOME}/.kube/config:/kube/config:ro \
  -e KUBECONFIG=/kube/config \
  fermdez96/k8dash:latest
```

Open your browser at **http://localhost:8080**.

> On Linux you may need `--network host` if your API server is reachable via
> `127.0.0.1` (e.g. with `kind`/`minikube`).

### Pin a specific version

In addition to `latest`, each release publishes its semver tag:

```bash
docker pull fermdez96/k8dash:1.36.17
docker run --rm -p 8080:8080 \
  -v ${HOME}/.kube/config:/kube/config:ro \
  -e KUBECONFIG=/kube/config \
  fermdez96/k8dash:1.36.17
```

### Environment variables

| Variable      | Default | Description                                            |
|---------------|---------|--------------------------------------------------------|
| `KUBECONFIG`  | —       | Path(s) to the kubeconfig. Supports several separated by `:` (Linux). |
| `K8DASH_ADDR` | `:8080` | Listen address and port of the HTTP server.            |
| `K8DASH_NAMESPACE` | *(auto-detected)* | Namespace where the authentication Secret `k8dash-auth` is persisted. In-cluster it is detected from the ServiceAccount. |
| `K8DASH_AUTH_DISABLED` | `false` | If `true`/`1`, **disables authentication**, ignoring the persisted configuration. Recovery mechanism if the admin gets locked out. |

---

## 🔨 Rebuild the image from this repository

This repository includes a [`Dockerfile`](Dockerfile) that builds the image from the
**precompiled binary** shipped alongside it, without needing the source code. Three
binaries are published: `k8dash` (generic), `k8dash-amd64` and `k8dash-arm64`.

```bash
git clone https://github.com/FerMdez/K8Dash.git
cd K8Dash

# Image with the generic binary
docker build -t k8dash:local .

# Or for a specific architecture (selects the matching binary)
docker build --build-arg BIN=k8dash-amd64 -t k8dash:amd64 .
docker build --build-arg BIN=k8dash-arm64 -t k8dash:arm64 .
```

> The official image on Docker Hub (`fermdez96/k8dash`) is **multi-arch**
> (`linux/amd64` + `linux/arm64`): `docker pull` selects the host's architecture.

---

## 🔐 Verify the binary integrity (checksum)

Every release publishes a [`SHA256SUMS.txt`](SHA256SUMS.txt) file with the
**SHA-256** checksum of the three binaries (`k8dash`, `k8dash-amd64` and
`k8dash-arm64`). It is available both in the root of this repository and among
the *assets* of each [GitHub Release](https://github.com/FerMdez/K8Dash/releases).
Verifying it after download guarantees that the binary **has not been tampered
with**.

The content uses the standard `sha256sum` format (one line per binary):

```text
<hash>  k8dash
<hash>  k8dash-amd64
<hash>  k8dash-arm64
```

Download the binary you need **and** the `SHA256SUMS.txt` file into the same
directory, then compare the checksum according to your operating system.

### 🐧 Linux

`sha256sum` ships with `coreutils`. Verify all sums in the file:

```bash
# Verify only entries whose files are present in the directory
sha256sum --ignore-missing -c SHA256SUMS.txt
# Expected output:  k8dash-amd64: OK
```

Or compute the hash of a specific binary and compare it manually:

```bash
sha256sum k8dash-amd64
```

### 🍏 macOS

macOS does not ship `sha256sum`, but it does ship `shasum` (with the `-a 256`
algorithm):

```bash
# Verify against the sums file
shasum -a 256 --ignore-missing -c SHA256SUMS.txt

# Or compute the hash of a specific binary
shasum -a 256 k8dash-amd64
```

> Alternatively: `openssl dgst -sha256 k8dash-amd64`.

### 🪟 Windows (PowerShell)

Use the `Get-FileHash` cmdlet and compare the result with the matching line in
`SHA256SUMS.txt`:

```powershell
# Compute the SHA-256 of the binary
Get-FileHash .\k8dash-amd64 -Algorithm SHA256

# Automatic comparison against the expected value from the sums file.
# Replace the binary name with the one you downloaded:
$file = 'k8dash-amd64'
$expected = (Select-String -Path .\SHA256SUMS.txt -Pattern "\s$file$").Line.Split(' ')[0]
$actual   = (Get-FileHash .\$file -Algorithm SHA256).Hash.ToLower()
if ($actual -eq $expected) { "OK: $file matches" } else { "ERROR: $file does NOT match" }
```

If the result does not match, **do not run the binary**: download it again.

---

## ☸️ Deployment inside the cluster

The manifest [`deploy/kubernetes.yaml`](deploy/kubernetes.yaml) creates a `Namespace`,
`ServiceAccount`, `ClusterRole`/`ClusterRoleBinding` with the minimum permissions, a
hardened `Deployment` (rootless, read-only FS, no capabilities), a `Service` and an example
`Ingress`.

The image used by the manifest is `fermdez96/k8dash:latest`.

```bash
# 1. Apply the manifests
kubectl apply -f deploy/kubernetes.yaml

# 2. Access it via port-forward
kubectl -n k8dash port-forward svc/k8dash 8080:80
```

Open your browser at **http://localhost:8080**.

When running inside the cluster, K8Dash automatically uses the mounted `ServiceAccount`:
**it does not need `KUBECONFIG`**.

### Pin a specific version in the deployment

The manifest uses `fermdez96/k8dash:latest`. To deploy a specific version, edit the
`image:` line of the `Deployment` or apply a *patch*:

```bash
kubectl -n k8dash set image deployment/k8dash k8dash=fermdez96/k8dash:1.36.17
```

### Exposure with Ingress (optional)

The manifest includes an example `Ingress` (commented out for the host
`dashboard.example.com`) prepared for **ingress-nginx** with the timeouts and headers
required for log/event streaming and the interactive terminal (WebSockets). Adjust the
`host`, the TLS `secretName` and, if you use another controller (e.g. Traefik), adapt the
annotations.

> [!IMPORTANT]
> Log/event streaming and the interactive terminal use WebSockets (routes `/api/ws/...`). If the proxy/Ingress does not forward the *Upgrade* or closes idle connections, you will see *"WebSocket connection failed"* in the browser.

---

## 🔒 Security

- K8Dash inherits **exactly the permissions** of the kubeconfig or ServiceAccount it runs
  with. Restrict the RBAC for sensitive environments.
- The included manifest applies the **principle of least privilege** and a hardened
  container (non-root, read-only FS, no capabilities).
- In the Secrets **listing** only metadata is shown; their values are only exposed on
  demand when opening/editing a specific Secret.
- Features such as **port-forward**, **terminal exec** and the **Helm** actions
  (rollback/uninstall) allow you to interact directly with the workloads: grant them only
  to trusted operators.
- Do not expose the dashboard directly to the Internet without an authentication layer.

---

## 📝 Changelog

See [`CHANGELOG.md`](CHANGELOG.md) for the change history of each version.

---

## 📝 License

Creative Commons Attribution-NonCommercial-ShareAlike (CC BY-NC-SA).

---

## ©️ Author

[`Fernando Méndez Torrubiano`](https://fermdez.net/)
