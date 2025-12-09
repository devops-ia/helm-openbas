# Basic installation

See [Customizing the chart before installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with comments:

```console
helm show values openaev/openaev
```

You may also helm show values on this chart's dependencies for additional options.

## Components

Basic installation will deploy the following components:

* MinIO
* OpenAEV caldera
* OpenAEV server
* OpenSearch
* PostgreSQL
* RabbitMQ

### OpenAEV server

Basic config server block to configure:

```yaml
env:
  OPENBAS_ADMIN_EMAIL: admin@openaev.io
  OPENBAS_ADMIN_PASSWORD: test
  OPENBAS_ADMIN_TOKEN: b1976749-8a53-4f49-bf04-cafa2a3458c1
  OPENBAS_COOKIE-SECURE: "true"
  INJECTOR_CALDERA_URL: http://openaev-ci-caldera:8888
  INJECTOR_CALDERA_PUBLIC_URL: http://openaev-ci-caldera:8888
  INJECTOR_CALDERA_API_KEY: 238cab90-5a9e-4c6f-8c7c-4ae07a50513f
  ...
```

Expose service:

```yaml
ingress:
  enabled: true
  hosts:
    - host: demo.mydomain.com
      paths:
        - path: /
          pathType: Prefix
```

### OpenAEV caldera

Basic config caldera service block to configure:

```yaml
env:
  CALDERA_URL: "http://localhost:8080"

  config:
    users:
      red:
        red: ChangeMe
    api_key_red: ChangeMe
    api_key: 238cab90-5a9e-4c6f-8c7c-4ae07a50513f
    crypt_salt: ChangeMe
    encryption_key: ChangeMe
    app.contact.http: http://openaev-ci-caldera:8888
    app.contact.tcp: 0.0.0.0:7010
    app.contact.udp: 0.0.0.0:7011
    app.contact.websocket: 0.0.0.0:7012
    app.contact.dns.domain: localhost
    app.contact.dns.socket: 0.0.0.0:53
    app.contact.tunnel.ssh.socket: 0.0.0.0:8022
    app.contact.tunnel.ssh.user_name: sandcat
    app.contact.tunnel.ssh.user_password: ChangeMe
    objects.planners.default: atomic
    ...
```

### MinIO

Server block to configure MinIO:

```yaml
env:
...
  MINIO_ENDPOINT: <release-name>-minio:9000
```

Basic config:

```yaml
minio:
  enabled: true
  mode: standalone
  auth:
    rootUser: ChangeMe
    rootPassword: ChangeMe

  persistence:
    enabled: false
```

Move `minio.auth.rootUser` and `minio.auth.rootPassword` to `secrets` block for `auth`:

```yaml
secrets:
  root-user: MySecretPassword
  root-password: MySecretErlangCookie
```

Configure `envFromSecrets` for server block:

```yaml
envFromSecrets:
  MINIO__ACCESS_KEY:
    name: <release-name>-credentials
    key: root-user
  MINIO__SECRET_KEY:
    name: <release-name>-credentials
    key: root-password
```

Configure Minio `minio.auth` with existing secret:

```yaml
minio.auth.existingSecret: <release-name>-credentials
```

More info. [chart values](https://github.com/bitnami/charts/blob/main/bitnami/minio/values.yaml)

### PostgreSQL

Server block to configure PostgreSQL:

```yaml
env:
  SPRING_DATASOURCE_URL: jdbc:postgresql://<release-name>-postgresql:5432/openaev
  SPRING_DATASOURCE_USERNAME: user
  SPRING_DATASOURCE_PASSWORD: ChangeMe
  ...
```

Basic config:

```yaml
postgresql:
  enabled: true
  replicaCount: 1

  auth:
    username: user
    password: ChangeMe

  persistence:
    enabled: false
```

More info. [chart values](https://github.com/bitnami/charts/blob/main/bitnami/postgresql/values.yaml)

### RabbitMQ

Server block to configure RabbitMQ:

```yaml
env:
...
  OPENBAS_RABBITMQ_HOSTNAME: <release-name>-rabbitmq
  OPENBAS_RABBITMQ_MANAGEMENT-PORT: 15672
  OPENBAS_RABBITMQ_PORT: 5672
  OPENBAS_RABBITMQ_USER: user
  OPENBAS_RABBITMQ_PASS: ChangeMe
```

Basic config:

```yaml
rabbitmq:
  enabled: true
  replicaCount: 1
  clustering:
    enabled: false

  auth:
    username: user
    password: ChangeMe
    erlangCookie: ChangeMe

  persistence:
    enabled: false
```

Move `rabbitmq.auth.password` and `rabbitmq.auth.erlangCookie` to `secrets` block for `auth`:

```yaml
secrets:
  rabbitmq-password: MySecretPassword
  rabbitmq-erlang-cookie: MySecretErlangCookie
```

Configure `envFromSecrets` for server block:

```yaml
envFromSecrets:
  RABBITMQ__PASSWORD:
    name: <release-name>-credentials
    key: rabbitmq-password
  RABBITMQ__ERLANGCOOKIE:
    name: <release-name>-credentials
    key: rabbitmq-erlang-cookie
```

Configure RabbitMQ `rabbitmq.auth` with existing secret:

```yaml
rabbitmq.auth.existingPasswordSecret: <release-name>-credentials
rabbitmq.auth.existingErlangSecret: <release-name>-credentials
```

More info. [chart values](https://github.com/bitnami/charts/blob/main/bitnami/rabbitmq/values.yaml)
