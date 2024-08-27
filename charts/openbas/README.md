# openbas

A Helm chart to deploy Open Breach and Attack Simulation platform

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| ialejandro | <hello@ialejandro.rocks> | <https://ialejandro.rocks> |

## Prerequisites

* Helm 3+

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | minio | 14.7.1 |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 15.5.24 |
| oci://registry-1.docker.io/bitnamicharts | rabbitmq | 14.6.6 |

## Add repository

```console
helm repo add openbas https://devops-ia.github.io/helm-openbas
helm repo update
```

## Install Helm chart (repository mode)

```console
helm install [RELEASE_NAME] openbas/openbas
```

This install all the Kubernetes components associated with the chart and creates the release.

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Install Helm chart (OCI mode)

Charts are also available in OCI format. The list of available charts can be found [here](https://github.com/devops-ia/helm-openbas/pkgs/container/helm-openbas%2Fopenbas).

```console
helm install [RELEASE_NAME] oci://ghcr.io/devops-ia/helm-openbas/openbas --version=[version]
```

## Uninstall Helm chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## OpenBAS

* [Environment configuration](https://docs.openbas.io/latest/deployment/configuration/#platform)
* [Collectors](https://github.com/OpenBAS-Platform/collectors/tree/main). Review `docker-compose.yaml` with the properly config or check collectors samples on [`collector-examples`](./collector-examples) folder.
* [Injectors](https://github.com/OpenBAS-Platform/injectors/tree/main). Review `docker-compose.yaml` with the properly config or check injectors samples on [`injector-examples`](./injector-examples) folder.

## Basic installation and examples

See [basic installation](docs/configuration.md) and [examples](docs/examples.md).

## Configuration

See [Customizing the chart before installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with comments:

```console
helm show values openbas/openbas
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling with CPU or memory utilization percentage |
| caldera | object | `{"affinity":{},"autoscaling":{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80},"config":{},"enabled":true,"env":{},"envFromSecrets":{},"image":{"pullPolicy":"IfNotPresent","repository":"openbas/caldera-server","tag":"5.0.0"},"ingress":{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]},"nodeSelector":{},"replicaCount":1,"resources":{},"service":{"port":8888,"targetPort":8888,"type":"ClusterIP"},"tolerations":[]}` | OpenBAS caldera-server deployment configuration |
| caldera.affinity | object | `{}` | Affinity for pod assignment |
| caldera.autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling with CPU or memory utilization percentage |
| caldera.config | object | `{}` | Caldera configuration Ref: https://github.com/OpenBAS-Platform/docker/blob/master/caldera.yml |
| caldera.env | object | `{}` | Environment variables to configure application Ref: https://docs.openbas.io/latest/deployment/configuration/#platform |
| caldera.envFromSecrets | object | `{}` | Secrets from variables |
| caldera.image | object | `{"pullPolicy":"IfNotPresent","repository":"openbas/caldera-server","tag":"5.0.0"}` | Image registry |
| caldera.ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Ingress configuration to expose app |
| caldera.nodeSelector | object | `{}` | Node labels for pod assignment |
| caldera.replicaCount | int | `1` | Number of replicas |
| caldera.resources | object | `{}` | The resources limits and requested |
| caldera.service | object | `{"port":8888,"targetPort":8888,"type":"ClusterIP"}` | Kubernetes service to expose Pod |
| caldera.service.port | int | `8888` | Kubernetes Service port |
| caldera.service.targetPort | int | `8888` | Pod expose port |
| caldera.service.type | string | `"ClusterIP"` | Kubernetes Service type. Allowed values: NodePort, LoadBalancer or ClusterIP |
| caldera.tolerations | list | `[]` | Tolerations for pod assignment |
| collectorGlobalEnv | string | `nil` | Collector Global environment |
| collectors | list | `[]` | Collectors Ref: https://github.com/OpenBAS-Platform/collectors |
| env | object | `{"INJECTOR_CALDERA_API_KEY":"ChangeMe","INJECTOR_CALDERA_PUBLIC_URL":"http://release-name-caldera:8888","INJECTOR_CALDERA_URL":"http://release-name-caldera:8888","MINIO_ENDPOINT":"release-name-minio:9000","OPENBAS_ADMIN_EMAIL":"admin@openbas.io","OPENBAS_ADMIN_PASSWORD":"ChangeMe","OPENBAS_ADMIN_TOKEN":"ChangeMe","OPENBAS_AUTH-LOCAL-ENABLE":true,"OPENBAS_BASE-URL":"http://localhost:8080","OPENBAS_RABBITMQ_HOSTNAME":"release-name-rabbitmq","OPENBAS_RABBITMQ_MANAGEMENT-PORT":15672,"OPENBAS_RABBITMQ_PASS":"ChangeMe","OPENBAS_RABBITMQ_PORT":5672,"OPENBAS_RABBITMQ_USER":"user","SERVER_ADDRESS":"0.0.0.0","SERVER_PORT":8080,"SPRING_DATASOURCE_PASSWORD":"ChangeMe","SPRING_DATASOURCE_URL":"jdbc:postgresql://release-name-postgresql:5432/openbas","SPRING_DATASOURCE_USERNAME":"user"}` | Environment variables to configure application Ref: https://docs.openbas.io/latest/deployment/configuration/#platform |
| envFromSecrets | object | `{}` | Secrets from variables |
| fullnameOverride | string | `""` | String to fully override openbas.fullname template |
| global | object | `{"imagePullSecrets":[],"imageRegistry":""}` | Global configuration |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"openbas/platform","tag":""}` | Image registry |
| imagePullSecrets | list | `[]` | Global Docker registry secret names as an array |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Ingress configuration to expose app |
| injectorGlobalEnv | string | `nil` | Injector Global environment |
| injectors | list | `[]` | Injectors Ref: https://github.com/OpenBAS-Platform/injectors |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":180,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Configure liveness checker Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes |
| livenessProbeCustom | object | `{}` | Custom livenessProbe |
| minio | object | `{"auth":{"rootPassword":"ChangeMe","rootUser":"ChangeMe"},"enabled":true,"mode":"standalone","persistence":{"enabled":false}}` | MinIO subchart deployment Ref: https://github.com/bitnami/charts/blob/main/bitnami/minio/values.yaml  |
| minio.auth.rootPassword | string | `"ChangeMe"` | Password for Minio root user |
| minio.auth.rootUser | string | `"ChangeMe"` | Minio root username |
| minio.enabled | bool | `true` | Enable or disable MinIO subchart |
| minio.mode | string | `"standalone"` | mode Minio server mode (`standalone` or `distributed`) Ref: https://docs.minio.io/docs/distributed-minio-quickstart-guide |
| minio.persistence | object | `{"enabled":false}` | Enable persistence using Persistent Volume Claims Ref: https://kubernetes.io/docs/user-guide/persistent-volumes/ |
| minio.persistence.enabled | bool | `false` | Enable MinIO data persistence using PVC. If false, use emptyDir |
| nameOverride | string | `""` | String to partially override openbas.fullname template (will maintain the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| postgresql | object | `{"auth":{"database":"openbas","password":"ChangeMe","username":"user"},"enabled":true,"persistence":{"enabled":false},"replicaCount":1}` | PostgreSQL subchart deployment Ref: https://github.com/bitnami/charts/blob/main/bitnami/postgresql/values.yaml |
| postgresql.auth | object | `{"database":"openbas","password":"ChangeMe","username":"user"}` | PostgreSQL Authentication parameters |
| postgresql.auth.database | string | `"openbas"` | PostgreSQL application database Ref: https://github.com/bitnami/containers/tree/main/bitnami/postgresql#environment-variables |
| postgresql.auth.password | string | `"ChangeMe"` | PostgreSQL application password Ref: https://github.com/bitnami/containers/tree/main/bitnami/postgresql#environment-variables |
| postgresql.auth.username | string | `"user"` | PostgreSQL application username Ref: https://github.com/bitnami/containers/tree/main/bitnami/postgresql#environment-variables |
| postgresql.enabled | bool | `true` | Enable or disable PostgreSQL subchart |
| postgresql.persistence | object | `{"enabled":false}` | Persistence parameters |
| postgresql.persistence.enabled | bool | `false` | Enable PostgreSQL data persistence using PVC |
| postgresql.replicaCount | int | `1` | Number of PostgreSQL replicas to deploy |
| rabbitmq | object | `{"auth":{"erlangCookie":"ChangeMe","password":"ChangeMe","username":"user"},"clustering":{"enabled":false},"enabled":true,"persistence":{"enabled":false},"replicaCount":1}` | RabbitMQ subchart deployment Ref: https://github.com/bitnami/charts/blob/main/bitnami/rabbitmq/values.yaml |
| rabbitmq.auth | object | `{"erlangCookie":"ChangeMe","password":"ChangeMe","username":"user"}` | RabbitMQ Authentication parameters |
| rabbitmq.auth.password | string | `"ChangeMe"` | RabbitMQ application password Ref: https://github.com/bitnami/containers/tree/main/bitnami/rabbitmq#environment-variables |
| rabbitmq.auth.username | string | `"user"` | RabbitMQ application username Ref: https://github.com/bitnami/containers/tree/main/bitnami/rabbitmq#environment-variables |
| rabbitmq.clustering | object | `{"enabled":false}` | Clustering settings |
| rabbitmq.clustering.enabled | bool | `false` | Enable RabbitMQ clustering |
| rabbitmq.enabled | bool | `true` | Enable or disable RabbitMQ subchart |
| rabbitmq.persistence | object | `{"enabled":false}` | Persistence parameters |
| rabbitmq.persistence.enabled | bool | `false` | Enable RabbitMQ data persistence using PVC |
| rabbitmq.replicaCount | int | `1` | Number of RabbitMQ replicas to deploy |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Configure readinessProbe checker Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes |
| readinessProbeCustom | object | `{}` | Custom readinessProbe |
| readyChecker | object | `{"enabled":true,"retries":30,"services":[{"name":"minio","port":9000},{"name":"postgresql","port":5432},{"name":"rabbitmq","port":5672}],"timeout":5}` | Enable or disable ready-checker |
| readyChecker.retries | int | `30` | Number of retries before giving up |
| readyChecker.services | list | `[{"name":"minio","port":9000},{"name":"postgresql","port":5432},{"name":"rabbitmq","port":5672}]` | List services |
| readyChecker.timeout | int | `5` | Timeout for each check |
| replicaCount | int | `1` | Number of replicas |
| resources | object | `{}` | The resources limits and requested |
| secrets | object | `{}` | Secrets values to create credentials and reference by envFromSecrets |
| service | object | `{"port":80,"targetPort":8080,"type":"ClusterIP"}` | Kubernetes service to expose Pod |
| service.port | int | `80` | Kubernetes Service port |
| service.targetPort | int | `8080` | Pod expose port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type. Allowed values: NodePort, LoadBalancer or ClusterIP |
| serviceAccount | object | `{"annotations":{},"automountServiceAccountToken":false,"create":true,"name":""}` | Enable creation of ServiceAccount |
| startupProbe | object | `{"enabled":true,"failureThreshold":30,"initialDelaySeconds":180,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Configure startupProbe checker Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-startup-probes |
| startupProbeCustom | object | `{}` | Custom startupProbe |
| testConnection | bool | `false` | Enable or disable test connection |
| tolerations | list | `[]` | Tolerations for pod assignment |
