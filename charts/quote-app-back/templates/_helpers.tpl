{{/*
Expand the name of the chart.
*/}}
{{- define "quote-app-back.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "quote-app-back.fullname" -}}
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
{{- define "quote-app-back.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "quote-app-back.labels" -}}
helm.sh/chart: {{ include "quote-app-back.chart" . }}
{{ include "quote-app-back.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "quote-app-back.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quote-app-back.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "quote-app-back.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "quote-app-back.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the application profil file
*/}}
{{- define "quote-app-back.application.yaml" -}}
quote:
  config:
    version: {{ .Values.quote.config.version }}
    geoloc:
      uri: https://${quote.config.geoloc.base-url}/search/${quote.config.geoloc.version-number}/reverseGeocode/${quote.config.geoloc.position}.${quote.config.geoloc.ext}?key=${quote.config.geoloc.key}
      base-url: {{ .Values.quote.config.geoloc.baseUrl }}
      version-number: {{ .Values.quote.config.geoloc.versionNumber }}
      position: "%s,%s"
      ext: {{ .Values.quote.config.geoloc.ext }}
      key: {{ .Values.quote.config.geoloc.key }}
    legalinfo:
      uri: https://${quote.config.legalinfo.base-url}/${quote.config.legalinfo.version}/suggestions?q=%s&longueur=%s
      base-url: {{ .Values.quote.config.legalinfo.baseUrl }}
      version: {{ .Values.quote.config.legalinfo.version }}
    security:
      filter-chain:
        login: {{ .Values.quote.config.security.filterChain.login }}
        api: {{ .Values.quote.config.security.filterChain.api }}
server:
  port: {{ .Values.quote.server.port }}
  servlet:
    context-path: /${quote.config.version}
  logging:
    level:
      org: {{ .Values.quote.logging.level.org }}
spring:
  flyway:
    schemas:
      {{- range .Values.quote.spring.flyway.schemas }}
      - {{ . }}
      {{- end }}
    locations:
      {{- range .Values.quote.spring.flyway.locations }}
      - {{ . }}
      {{- end }}
  jooq:
    sql-dialect: {{ .Values.quote.spring.jooq.dialect }}
  application:
    name: {{ .Values.quote.spring.application.name }}
  datasource:
    url: {{ .Values.quote.spring.datasource.url }}
    username: {{ .Values.quote.spring.datasource.username }}
    password: {{ .Values.quote.spring.datasource.password }}
  mail:
    host: {{ .Values.quote.spring.mail.host }}
    port: {{ .Values.quote.spring.mail.port }}
    username: {{ .Values.quote.spring.mail.username }}
    password: {{ .Values.quote.spring.mail.password }}
    properties:
      mail:
        protocol: {{ .Values.quote.spring.mail.properties.mail.protocol }}
        tls: {{ .Values.quote.spring.mail.properties.mail.tls }}
        smtp:
          auth: {{ .Values.quote.spring.mail.properties.mail.smtp.auth }}
          starttls:
            enable: {{ .Values.quote.spring.mail.properties.mail.smtp.starttls.enable }}
  security:
    oauth2:
      client:
        registration:
          keycloak:
            client-id: {{ .Values.quote.spring.security.oauth2.client.registration.keycloak.clientId }}
            client-secret: {{ .Values.quote.spring.security.oauth2.client.registration.keycloak.clientSecret }}
        provider:
          keycloak:
            authorization-uri: {{ .Values.quote.spring.security.oauth2.client.provider.keycloak.authorizationUri }}
            token-uri: {{ .Values.quote.spring.security.oauth2.client.provider.keycloak.tokenUri }}
            user-info-uri: {{ .Values.quote.spring.security.oauth2.client.provider.keycloak.userInfoUri }}
            issuer-uri: {{ .Values.quote.spring.security.oauth2.client.provider.keycloak.issuerUri }}
            jwk-set-uri: {{ .Values.quote.spring.security.oauth2.client.provider.keycloak.jwkSetUri }}
            user-name-attribute: {{ .Values.quote.spring.security.oauth2.client.provider.keycloak.userNameAttribute }}
      resourceserver:
        jwt:
          issuer-uri: {{ .Values.quote.spring.security.oauth2.resourceserver.jwt.issuerUri }}
          jwk-set-uri: {{ .Values.quote.spring.security.oauth2.resourceserver.jwt.jwkSetUri }}
{{- end -}}
