networkinstance:
- name: {{.name}}
  type: {{.type}}
  description: k8s-{{.name}}
  admin-state: enable
  ip-forwarding:
    receive-ipv4-check: false
    receive-ipv6-check: false
{{- if ne 0 (len .interfaces)}}
  interface:
{{- range $index, $itfce := .interfaces}}
{{- if eq $itfce.name "interface"}}
  - name: ethernet-{{$itfce.port}}/{{$itfce.id}}
{{- end }}
{{- if eq $itfce.name "system"}}
  - name: {{$itfce.name}}.{{$itfce.id}}
{{- end }}
{{- end}}
{{- end}}
