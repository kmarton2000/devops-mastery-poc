{{/* Globális namespace meghatározása */}}
{{- define "devops-suite.namespace" -}}
{{- default .Values.global.namespace .Release.Namespace -}}
{{- end -}}