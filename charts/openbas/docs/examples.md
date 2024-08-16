# Examples

## Global: create secrets

Use `secrets` to create secrets to reference with `envFromSecrets`. By default the secret is created in the same namespace of the release.

> [!IMPORTANT]
> Secrets are encoded with base64.

Name template `{{ include "openbas.fullname" . }}-credentials`. For example if release name is `openbas-ci` the secret name will be `openbas-ci-credentials`.

```yaml
kind: Secret
type: Opaque
metadata:
  name: openbas-ci-credentials
  labels:
    ...
data:
  my_secret: dGVzdA==
```

Can reference the secret using `envFromSecrets` in any (is the same `Secret` for each component):

* server
* caldera
* collector

> [!NOTE]
> A suggestion to facilitate the management of secrets is to use prefixes. For example, for collector secrets save `CONNECTOR_MISP_MY_SECRET` to reference `MISP` collector.

## Server: health checks

Enable `testConnection` to check if the service is reachable.

```yaml
testConnection: true
```

Or check each service using `readyChecker` to check if the services which depends to run OpenBAS are ready.

> [!IMPORTANT]
> Only works with servies which are deployed like deps in this chart.

```yaml
readyChecker:
  enabled: true
  # -- Number of retries before giving up
  retries: 30
  # -- Timeout for each check
  timeout: 5
  # -- List services
  services:
  - name: minio
    port: 9000
  - name: postgresql
    port: 5432
  - name: rabbitmq
    port: 5672
```

In deep this config are deployed as a initial container which check the services (review [deployment.yaml](../templates/server/deployment.yaml)):

```yaml
      initContainers:
      {{- range $service := .Values.readyChecker.services }}
      - name: ready-checker-{{ $service.name }}
        image: busybox
        command:
          - 'sh'
          - '-c'
          - 'RETRY=0; until [ $RETRY -eq {{ $.Values.readyChecker.retries }} ]; do nc -zv {{ $.Values.fullnameOverride | default $.Release.Name }}-{{ $service.name }} {{ $service.port }} && break; echo "[$RETRY/{{ $.Values.readyChecker.retries }}] waiting service {{ $.Values.fullnameOverride | default $.Release.Name }}-{{ $service.name }}:{{ $service.port }} is ready"; sleep {{ $.Values.readyChecker.timeout }}; RETRY=$(($RETRY + 1)); done'
      {{- end }}
```

Output:

```yaml
...
      initContainers:
      - name: ready-checker-minio
        image: busybox
        command:
          - 'sh'
          - '-c'
          - 'RETRY=0; until [ $RETRY -eq 30 ]; do nc -zv openbas-ci-minio 9000 && break; echo "[$RETRY/30] waiting service openbas-ci-minio:9000 is ready"; sleep 5; RETRY=$(($RETRY + 1)); done'
      - name: ready-checker-postgresql
        image: busybox
        command:
          - 'sh'
          - '-c'
          - 'RETRY=0; until [ $RETRY -eq 30 ]; do nc -zv openbas-ci-postgresql 5432 && break; echo "[$RETRY/30] waiting service openbas-ci-postgresql:5432 is ready"; sleep 5; RETRY=$(($RETRY + 1)); done'
      - name: ready-checker-rabbitmq
        image: busybox
        command:
          - 'sh'
          - '-c'
          - 'RETRY=0; until [ $RETRY -eq 30 ]; do nc -zv openbas-ci-rabbitmq 5672 && break; echo "[$RETRY/30] waiting service openbas-ci-rabbitmq:5672 is ready"; sleep 5; RETRY=$(($RETRY + 1)); done'
```

## Connector: sample complete

```yaml
collectors:
# https://github.com/OpenBAS-Platform/collectors/tree/main/microsoft-entra
- name: microsoft-entra
  enabled: true
  replicas: 1
  image:
    repository: openbas/collector-microsoft-entra
  env:
    OPENBAS_URL: "XXXX"
    OPENBAS_TOKEN: "XXXX"
    COLLECTOR_ID: ChangeMe
    COLLECTOR_NAME: "Microsoft Entra"
    COLLECTOR_LOG_LEVEL: error
    MICROSOFT_ENTRA_TENANT_ID: "XXXX"
    MICROSOFT_ENTRA_CLIENT_ID: "XXXX"
    INCLUDE_EXTERNAL: "false"
  envFromSecrets:
    MICROSOFT_ENTRA_CLIENT_SECRET:
      name:  my-secret-credentials
      key: MICROSOFT_ENTRA_CLIENT_SECRET
  resources:
    requests:
      memory: 128Mi
      cpu: 100m
    limits:
      memory: 128Mi
```

You can config which node to run the collector using nodeSelector and tolerations.

```yaml
collector:
- name: microsoft-entra
  ...
  nodeSelector:
    project: "openbas"
  tolerations:
    - key: "project"
      operator: "Equal"
      value: "openbas"
      effect: "NoSchedule"
```

Or you can use affinity to run the collector in different node if you increase replicas.

```yaml
- name: microsoft-entra
  ...
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: openbas.collector
                operator: In
                values:
                  - microsoft-entra
          topologyKey: kubernetes.io/hostname
```
