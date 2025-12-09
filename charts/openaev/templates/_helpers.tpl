{{/*
Expand the name of the chart.
*/}}
{{- define "openaev.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openaev.fullname" -}}
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
{{- define "openaev.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openaev.labels" -}}
helm.sh/chart: {{ include "openaev.chart" . }}
{{ include "openaev.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openaev.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openaev.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openaev.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openaev.fullname" .) .Values.serviceAccount.name }}
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
{{- define "openaev.serverComponentLabel" -}}
openaev.component: server
{{- end -}}

{{/*
Generate labels for server component
*/}}
{{- define "openaev.serverLabels" -}}
{{- toYaml (merge ((include "openaev.labels" .) | fromYaml) ((include "openaev.serverComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Generate selectorLabels for server component
*/}}
{{- define "openaev.selectorServerLabels" -}}
{{- toYaml (merge ((include "openaev.selectorLabels" .) | fromYaml) ((include "openaev.serverComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch the label selector on an object
This template will add a labelSelector using matchLabels to the object referenced at _target if there is no labelSelector specified.
The matchLabels are created with the selectorLabels template.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "openaev.patchSelectorServerLabels" -}}
{{- if not (hasKey ._target "labelSelector") }}
{{- $selectorLabels := (include "openaev.selectorServerLabels" .) | fromYaml }}
{{- $_ := set ._target "labelSelector" (dict "matchLabels" $selectorLabels) }}
{{- end }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch topology spread constraints
This template uses the openaev.selectorLabels template to add a labelSelector to topologySpreadConstraints if one isn't specified.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "openaev.patchTopologySpreadConstraintsServer" -}}
{{- range $constraint := .Values.topologySpreadConstraints }}
{{- include "openaev.patchSelectorServerLabels" (merge (dict "_target" $constraint (include "openaev.selectorServerLabels" $)) $) }}
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
{{- define "openaev.calderaComponentLabel" -}}
openaev.component: caldera
{{- end -}}

{{/*
Generate labels for caldera component
*/}}
{{- define "openaev.calderaLabels" -}}
{{- toYaml (merge ((include "openaev.labels" .) | fromYaml) ((include "openaev.calderaComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Generate selectorLabels for caldera component
*/}}
{{- define "openaev.selectorCalderaLabels" -}}
{{- toYaml (merge ((include "openaev.selectorLabels" .) | fromYaml) ((include "openaev.calderaComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch the label selector on an object
This template will add a labelSelector using matchLabels to the object referenced at _target if there is no labelSelector specified.
The matchLabels are created with the selectorLabels template.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "openaev.patchSelectorCalderaLabels" -}}
{{- if not (hasKey ._target "labelSelector") }}
{{- $selectorLabels := (include "openaev.selectorCalderaLabels" .) | fromYaml }}
{{- $_ := set ._target "labelSelector" (dict "matchLabels" $selectorLabels) }}
{{- end }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch topology spread constraints
This template uses the openaev.selectorLabels template to add a labelSelector to topologySpreadConstraints if one isn't specified.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "openaev.patchTopologySpreadConstraintsCaldera" -}}
{{- range $constraint := .Values.caldera.topologySpreadConstraints }}
{{- include "openaev.patchSelectorCalderaLabels" (merge (dict "_target" $constraint (include "openaev.selectorCalderaLabels" $)) $) }}
{{- end }}
{{- end }}
