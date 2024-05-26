# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

# Setting SHELL to bash allows bash commands to be executed by recipes.
# This is a requirement for 'setup-envtest.sh' in the test target.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec


.PHONY: install
install: 
	curl -sL https://github.com/henderiw/knetctl/raw/main/install.sh

.PHONY: all
all:
	mkdir -p kubenet/artifacts/out
	knetctl release artifacts/kubenet-release.yaml artifacts/out





