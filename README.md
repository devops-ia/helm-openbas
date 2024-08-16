# OpenBAS Helm Chart

[OpenBAS](https://github.com/OpenBAS-Platform/openbas) is an open source platform allowing organizations to plan, schedule and conduct cyber adversary simulation campaign and tests.

## Usage

Charts are available in:

* [Chart Repository](https://helm.sh/docs/topics/chart_repository/)
* [OCI Artifacts](https://helm.sh/docs/topics/registries/)

### Chart Repository

#### Add repository

```console
helm repo add openbas https://devops-ia.github.io/helm-openbas
helm repo update
```

#### Install Helm chart

```console
helm install [RELEASE_NAME] openbas/openbas
```

This install all the Kubernetes components associated with the chart and creates the release.

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

### OCI Registry

Charts are also available in OCI format. The list of available charts can be found [here](https://github.com/devops-ia/helm-openbas/pkgs/container/helm-openbas%2Fopenbas).

#### Install Helm chart

```console
helm install [RELEASE_NAME] oci://ghcr.io/devops-ia/helm-openbas/openbas --version=[version]
```

## OpenBAS chart

Can be found in [openbas chart](https://github.com/devops-ia/helm-openbas/tree/main/charts/openbas).
