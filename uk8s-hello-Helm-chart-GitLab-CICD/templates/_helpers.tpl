{{- define "uk8s-hello.fullname" -}}
{{- printf "%s" .Values.releaseName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
