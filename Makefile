# ---- Config ----

# Provider coordinates used by Terraform
PLUGIN_HOSTNAME  ?= local
PLUGIN_NAMESPACE ?= esxi
PLUGIN_NAME      ?= esxi

# Version of your provider (override with: make deploy VERSION=1.11.0)
VERSION ?= 1.11.0

# Detect OS and ARCH for Terraform plugin dir
OS   := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH_RAW := $(shell uname -m)

ifeq ($(ARCH_RAW),x86_64)
  ARCH := amd64
else ifeq ($(ARCH_RAW),arm64)
  ARCH := arm64
else
  ARCH := $(ARCH_RAW)
endif

# Where Terraform expects the plugin
PLUGIN_DIR := $(HOME)/.terraform.d/plugins/$(PLUGIN_HOSTNAME)/$(PLUGIN_NAMESPACE)/$(PLUGIN_NAME)/$(VERSION)/$(OS)_$(ARCH)

# Source binary (what you built)
# Example expected name: terraform-provider-esxi_v1.11.0_darwin_arm64
BINARY_SRC ?= ./terraform-provider-esxi_v$(VERSION)_$(OS)_$(ARCH)

# Destination binary name (inside plugin dir)
BINARY_DST := $(PLUGIN_DIR)/terraform-provider-esxi_v$(VERSION)

# ---- Targets ----

.PHONY: deploy show-path get-go build-linux build-mac


get-go: #https://github.com/travis-ci/gimme
	gimme 1.11.5

build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-w -extldflags "-static"' -o terraform-provider-esxi_`cat version`

build-mac:
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -a -ldflags '-w -extldflags "-static"' -o terraform-provider-esxi_`cat version`_darwin_arm64

deploy:
	@echo "Deploying provider version $(VERSION) to:"
	@echo "  $(PLUGIN_DIR)"
	mkdir -p "$(PLUGIN_DIR)"
	cp "$(BINARY_SRC)" "$(BINARY_DST)"
	chmod +x "$(BINARY_DST)"
	@echo "Done. Provider installed at:"
	@echo "  $(BINARY_DST)"

show-path:
	@echo "$(PLUGIN_DIR)"
