# Upgrade guide: v1 to v2

## Overview

OpenAEV Helm Chart v2 replaces the bundled **MinIO** object-storage subchart with **RustFS**. This is a breaking change: the storage backend, its Helm values shape, and the service it exposes are all different. There is no configuration-only compatibility path.

> [!WARNING]
> **Data does not migrate automatically.** MinIO and RustFS are different storage engines with different on-disk formats. Files already stored in your MinIO deployment will **not** appear in RustFS after the upgrade unless you migrate them yourself first. Read the [Data migration](#data-migration-required-before-upgrading) section below before running `helm upgrade`.

## What's new in v2

* The `minio` subchart dependency is replaced by `rustfs` (`https://charts.rustfs.com`), deployed in **standalone mode** (single pod) to match the previous MinIO footprint.
* RustFS is S3-API compatible, so OpenAEV's own configuration (`MINIO_ENDPOINT`, and any `envFromSecrets` wired to `MINIO_ACCESS-KEY`/`MINIO_ACCESS-SECRET`) keeps the same env var **names** — only the values change.
* RustFS's chart is currently **beta software** (chart `0.12.0`, app version `1.0.0-beta.12`). Pilot this upgrade in a staging environment before touching production.
* RustFS is not one of OpenAEV's officially documented object-storage backends (the docs list MinIO or AWS S3) — this deviation mirrors the same choice already made in the sibling `helm-opencti` chart.

## Prerequisites

* Helm 3.x installed and configured
* Kubernetes cluster access with appropriate permissions
* Current OpenAEV deployment running on v1
* A dynamic-provisioning-capable StorageClass (RustFS standalone mode always uses PVCs — there is no emptyDir/ephemeral option)
* A migration plan for existing MinIO data (see below) — do not skip this if you have data you care about

## Data migration (required before upgrading)

RustFS is a from-scratch storage engine; it does not read MinIO's on-disk format. If you have files worth keeping, migrate them **before** decommissioning MinIO:

1. Keep your current v1 release running (still on MinIO).
2. Deploy RustFS alongside it — either by doing a dry-run of the v2 upgrade values in a separate namespace/release, or by installing the `rustfs` subchart standalone with the values shown below.
3. Use an S3-compatible copy tool (e.g. [`mc mirror`](https://min.io/docs/minio/linux/reference/minio-mc/mc-mirror.html), pointed at both the old MinIO endpoint and the new RustFS endpoint, or `rclone sync`) to copy every object across:

   ```bash
   mc alias set old-minio http://<release>-minio:9000 <minio-access-key> <minio-secret-key>
   mc alias set new-rustfs http://<release>-rustfs-svc:9000 <rustfs-access-key> <rustfs-secret-key>
   mc mirror old-minio/openaev-bucket new-rustfs/openaev-bucket
   ```

4. Verify object counts/checksums match between source and destination before proceeding.
5. Only then perform the `helm upgrade` to v2 and decommission the old MinIO release.

If you're upgrading a non-critical or dev/test environment, you can skip this and accept a clean slate — but this is a deliberate choice, not a side effect of the upgrade.

## Upgrade steps

### Step 1: Migrate data (see above), then upgrade

```bash
helm repo add openaev https://devops-ia.github.io/helm-openaev
helm repo update

helm upgrade your-release-name openaev/openaev \
  --version 2.x.x                              \
  -f your-updated-values.yaml                  \
  --wait                                       \
  --timeout 600s
```

### Step 2: Verification

```bash
# RustFS pod is Running
kubectl get pods -l app.kubernetes.io/name=rustfs

# RustFS service is reachable (note the -svc suffix)
kubectl run -it --rm netcheck --image=busybox --restart=Never -- \
  nc -zv your-release-name-rustfs-svc 9000

# Server logs show a successful S3 connection, no ECONNREFUSED/auth errors
kubectl logs -l app.kubernetes.io/name=openaev | grep -i "storage"

# End-to-end: upload a file through the OpenAEV UI and confirm it's retrievable
```

## Configuration migration details

| v1 (MinIO) | v2 (RustFS) | Notes |
| --- | --- | --- |
| `minio.enabled` | `rustfs.enabled` | same semantics |
| `minio.mode: standalone` | `rustfs.mode.standalone.enabled: true`<br>`rustfs.mode.distributed.enabled: false` | RustFS's default is `distributed` — this chart forces standalone to match MinIO's footprint |
| `minio.rootUser` / `minio.rootPassword` | `rustfs.secret.rustfs.access_key` / `secret_key` | RustFS refuses to render with its own well-known default credentials; any other non-empty value (including `ChangeMe`) is accepted |
| `minio.persistence.enabled: false` (emptyDir) | *(no equivalent)* | RustFS standalone always provisions PVCs via `rustfs.storageclass`. This chart defaults `rustfs.storageclass.name: ""` so your cluster's default StorageClass is used |
| `env.MINIO_ENDPOINT: <release>-minio:9000` | `env.MINIO_ENDPOINT: <release>-rustfs-svc:9000` | RustFS's Service name always carries a `-svc` suffix regardless of `fullnameOverride` — this is easy to miss |
| `envFromSecrets.MINIO_ACCESS-KEY` → secret key `rootUser` | → secret key `RUSTFS_ACCESS_KEY` | RustFS's generated Secret (`<fullname>-secret`) uses different key names |
| `envFromSecrets.MINIO_ACCESS-SECRET` → secret key `rootPassword` | → secret key `RUSTFS_SECRET_KEY` | same as above |
| `readyChecker.services: [{name: minio, port: 9000}]` | `readyChecker.services: [{name: rustfs, address: <release>-rustfs-svc, port: 9000}]` | the `-svc` suffix breaks this chart's usual auto-address inference (`<release>-<service.name>`), so `address` must be set explicitly for the rustfs entry |

## Migration validation

* `kubectl get pods -l app.kubernetes.io/name=rustfs` → `Running`, `1/1`
* `kubectl get pvc` → the two RustFS PVCs (`<fullname>-data`, `<fullname>-logs`) are `Bound`
* `nc -zv <release>-rustfs-svc 9000` succeeds
* OpenAEV server logs show a successful S3/storage connection with no errors
* The `ready-checker-rustfs` init container on server/collector/injector pods succeeds without retrying (this is exactly where a missed `-svc` suffix would manifest as a permanent connection failure)
* A real file upload/download through the OpenAEV UI works end-to-end

## Rollback

> [!IMPORTANT]
> Rolling back after decommissioning MinIO is **not** a simple `helm rollback`. If the original MinIO PVC/release was deleted, its data is gone — `helm rollback` restores the chart configuration, not the object storage contents. Only roll back if you still have the original MinIO PVC intact, or if you accepted data loss going in.

```bash
# Only safe if MinIO's PVC/data still exists
helm rollback your-release-name

helm history your-release-name
kubectl get pods -l app.kubernetes.io/name=openaev
```
