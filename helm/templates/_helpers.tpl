{{/*
Expand the name of the chart.
*/}}
{{- define "tp-cicd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "tp-cicd.fullname" -}}
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
Common labels
*/}}
{{- define "tp-cicd.labels" -}}
helm.sh/chart: {{ include "tp-cicd.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "tp-cicd.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tp-cicd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tp-cicd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
