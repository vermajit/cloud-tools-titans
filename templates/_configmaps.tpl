{{- define "titan-mesh-helm-lib-chart.configmap" }}
  {{- $global := $.Values.global -}}
  {{- $titanSideCars := mergeOverwrite (deepCopy ($global.titanSideCars | default dict)) ($.Values.titanSideCars | default dict) -}}
  {{- if $titanSideCars }}
    {{- $envoy := $titanSideCars.envoy -}}
    {{- $logs := $titanSideCars.logs -}}
    {{- $opa := $titanSideCars.opa -}}
    {{- $ratelimit := $titanSideCars.ratelimit -}}
    {{- $envoyEnabled := eq (include "titan-mesh-helm-lib-chart.envoyEnabled" $titanSideCars) "true" -}}
    {{- $opaEnabled := eq (include "titan-mesh-helm-lib-chart.opaEnabled" $titanSideCars) "true" -}}
    {{- $ratelimitEnabled := eq (include "titan-mesh-helm-lib-chart.ratelimitEnabled" $titanSideCars) "true" -}}
    {{- $appName := include "titan-mesh-helm-lib-chart.app-name" . -}}
    {{- if $envoyEnabled }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $.Release.Name }}-{{ printf "%s-titan-configs" $appName }}
data:
{{ include "titan-mesh-helm-lib-chart.configs.envoy" . | indent 2 }}
{{ include "titan-mesh-helm-lib-chart.configs.envoy-sds" . | indent 2 }}
      {{- if $opaEnabled }}
{{ include "titan-mesh-helm-lib-chart.configs.opa" . | indent 2 }}
{{ include "titan-mesh-helm-lib-chart.configs.opa-policy" . | indent 2 }}
{{ include "titan-mesh-helm-lib-chart.configs.opa-policy-tokenspec" . | indent 2 }}
{{ include "titan-mesh-helm-lib-chart.configs.opa-policy-ingress" . | indent 2 }}
        {{- range $k, $v := $opa.customPolicies }}
          {{- if ne $k "tokenSpec" }}
  {{ printf "policy-%s.rego: |" $k }}
{{ $v | indent 4 }}
          {{- end }}
        {{- end }}
      {{- end }}
      {{- if $ratelimitEnabled }}
{{ include "titan-mesh-helm-lib-chart.configs.ratelimit" . | indent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}