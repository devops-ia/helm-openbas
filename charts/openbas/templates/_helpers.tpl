{{/*
Expand the name of the chart.
*/}}
{{- define "openbas.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openbas.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "openbas.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openbas.labels" -}}
helm.sh/chart: {{ include "openbas.chart" . }}
{{ include "openbas.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openbas.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openbas.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openbas.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openbas.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
#######################
SERVER SECTION
#######################
*/}}

{{/*
Default server component
*/}}
{{- define "openbas.serverComponentLabel" -}}
openbas.component: server
{{- end -}}

{{/*
Generate labels for server component
*/}}
{{- define "openbas.serverLabels" -}}
{{- toYaml (merge ((include "openbas.labels" .) | fromYaml) ((include "openbas.serverComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Generate selectorLabels for server component
*/}}
{{- define "openbas.selectorServerLabels" -}}
{{- toYaml (merge ((include "openbas.selectorLabels" .) | fromYaml) ((include "openbas.serverComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch the label selector on an object
This template will add a labelSelector using matchLabels to the object referenced at _target if there is no labelSelector specified.
The matchLabels are created with the selectorLabels template.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "openbas.patchSelectorServerLabels" -}}
{{- if not (hasKey ._target "labelSelector") }}
{{- $selectorLabels := (include "openbas.selectorServerLabels" .) | fromYaml }}
{{- $_ := set ._target "labelSelector" (dict "matchLabels" $selectorLabels) }}
{{- end }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch topology spread constraints
This template uses the openbas.selectorLabels template to add a labelSelector to topologySpreadConstraints if one isn't specified.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "openbas.patchTopologySpreadConstraintsServer" -}}
{{- range $constraint := .Values.topologySpreadConstraints }}
{{- include "openbas.patchSelectorServerLabels" (merge (dict "_target" $constraint (include "openbas.selectorServerLabels" $)) $) }}
{{- end }}
{{- end }}

{{/*
#######################
CALDERA SECTION
#######################
*/}}

{{/*
Default caldera component
*/}}
{{- define "openbas.calderaComponentLabel" -}}
openbas.component: caldera
{{- end -}}

{{/*
Generate labels for caldera component
*/}}
{{- define "openbas.calderaLabels" -}}
{{- toYaml (merge ((include "openbas.labels" .) | fromYaml) ((include "openbas.calderaComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Generate selectorLabels for caldera component
*/}}
{{- define "openbas.selectorCalderaLabels" -}}
{{- toYaml (merge ((include "openbas.selectorLabels" .) | fromYaml) ((include "openbas.calderaComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch the label selector on an object
This template will add a labelSelector using matchLabels to the object referenced at _target if there is no labelSelector specified.
The matchLabels are created with the selectorLabels template.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "openbas.patchSelectorCalderaLabels" -}}
{{- if not (hasKey ._target "labelSelector") }}
{{- $selectorLabels := (include "openbas.selectorCalderaLabels" .) | fromYaml }}
{{- $_ := set ._target "labelSelector" (dict "matchLabels" $selectorLabels) }}
{{- end }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch topology spread constraints
This template uses the openbas.selectorLabels template to add a labelSelector to topologySpreadConstraints if one isn't specified.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "openbas.patchTopologySpreadConstraintsCaldera" -}}
{{- range $constraint := .Values.caldera.topologySpreadConstraints }}
{{- include "openbas.patchSelectorCalderaLabels" (merge (dict "_target" $constraint (include "openbas.selectorCalderaLabels" $)) $) }}
{{- end }}
{{- end }}
