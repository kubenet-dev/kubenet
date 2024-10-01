interface:
- name: {{.name}}
  description: k8s-{{.name}}
  admin-state: enable
{{- if .vlanTagging}}
  vlan-tagging: true
{{- end}}

