{{- define "n8n.labels" -}}
app.kubernetes.io/name: n8n
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "n8n.selector" -}}
app.kubernetes.io/name: n8n
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* URL pública: el listener del ALB, no el NodePort (el worker es privado). */}}
{{- define "n8n.baseUrl" -}}
http://{{ required "publicHost es obligatorio" .Values.publicHost }}:{{ .Values.publicPort }}/
{{- end -}}

{{/*
Variables comunes a main y workers: misma base de datos, misma cola y misma
clave de cifrado. La clave debe ser estable: si cambia, las credenciales
guardadas en PostgreSQL dejan de poder descifrarse.
*/}}
{{- define "n8n.env" -}}
- name: GENERIC_TIMEZONE
  value: {{ .Values.timezone | quote }}
- name: TZ
  value: {{ .Values.timezone | quote }}
- name: N8N_ENCRYPTION_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.existingSecret }}
      key: N8N_ENCRYPTION_KEY
- name: DB_TYPE
  value: postgresdb
- name: DB_POSTGRESDB_HOST
  value: {{ required "postgres.host es obligatorio" .Values.postgres.host | quote }}
- name: DB_POSTGRESDB_PORT
  value: {{ .Values.postgres.port | quote }}
- name: DB_POSTGRESDB_DATABASE
  value: {{ .Values.postgres.database | quote }}
- name: DB_POSTGRESDB_USER
  value: {{ .Values.postgres.user | quote }}
- name: DB_POSTGRESDB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.existingSecret }}
      key: DB_POSTGRESDB_PASSWORD
- name: DB_POSTGRESDB_SSL_ENABLED
  value: {{ .Values.postgres.ssl | quote }}
- name: DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED
  value: {{ .Values.postgres.sslRejectUnauthorized | quote }}
- name: EXECUTIONS_MODE
  value: queue
- name: QUEUE_BULL_REDIS_HOST
  value: {{ required "redis.host es obligatorio" .Values.redis.host | quote }}
- name: QUEUE_BULL_REDIS_PORT
  value: {{ .Values.redis.port | quote }}
- name: QUEUE_BULL_REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.existingSecret }}
      key: QUEUE_BULL_REDIS_PASSWORD
- name: QUEUE_BULL_REDIS_TLS
  value: {{ .Values.redis.tls | quote }}
- name: QUEUE_HEALTH_CHECK_ACTIVE
  value: "true"
- name: N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS
  value: "true"
{{- end -}}
