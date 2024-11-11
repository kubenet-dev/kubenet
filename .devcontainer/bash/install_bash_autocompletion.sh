#!/bin/bash

###
### Shell completions
###
# generate containerlab completions
containerlab completion bash > "/usr/share/bash-completion/completions/containerlab"
# add clab alias to the completions
sed -i 's/compdef _containerlab containerlab/compdef _containerlab containerlab clab/g' /usr/share/bash-completion/completions/containerlab
# generate gnmic completions
gnmic completion bash > "/usr/share/bash-completion/completions/gnmic"
# generate gnoic completions
gnoic completion bash > "/usr/share/bash-completion/completions/gnoic"
# generate gh completions
gh completion -s bash > "/usr/share/bash-completion/completions/gh"
# kubectl completions
kubectl completion bash > "/usr/share/bash-completion/completions/kubectl"
# kind completions
kind completion bash > "/usr/share/bash-completion/completions/kind"
# kubenetctl completions
kubenetctl completion bash > "/usr/share/bash-completion/completions/kubenetctl"
# choreoctl completions
choreoctl completion bash > "/usr/share/bash-completion/completions/choreoctl"
# docker completions
docker completion bash > "/usr/share/bash-completion/completions/docker"
# k9s completions
k9s completion bash > "/usr/share/bash-completion/completions/k9s"