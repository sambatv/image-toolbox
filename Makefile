# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL := /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

# -----------------------------------------------------------------------------
# Define build variables
# -----------------------------------------------------------------------------

# Set image identity.
REGISTRY    ?= ghcr.io
REPOSITORY  ?= sambatv/image-toolbox
IMAGE       ?= $(REGISTRY)/$(REPOSITORY)
TAG         ?= $(shell date +%Y-%m-%d)  # CalVer, not SemVer!

# Set image platform.
OS       ?= linux
ARCH     ?= amd64
PLATFORM ?= $(OS)/$(ARCH)

# Get the tools to install with asdf
TOOLS = $(shell cat .tool-versions | awk '{print $$1}')

# Get GitHub identity.
GITHUB_USERNAME ?= sambatv

# -----------------------------------------------------------------------------
# Define build targets
# -----------------------------------------------------------------------------

# Display help information by default.
.DEFAULT_GOAL := help

##@ Info targets

# The 'help' target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
#
# See https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters for more
# info on the usage of ANSI control characters for terminal formatting.
#
# See http://linuxcommand.org/lc3_adv_awk.php for more info on the awk command.

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: vars
vars: ## Show configurable build variables
	@echo "REGISTRY:    $(REGISTRY)"
	@echo "REPOSITORY:  $(REPOSITORY)"
	@echo "IMAGE:       $(IMAGE)"
	@echo "TAG:         $(TAG)"
	@echo "OS:          $(OS)"
	@echo "ARCH:        $(ARCH)"
	@echo "PLATFORM:    $(PLATFORM)"

##@ Dependency targets

.PHONY: tools
tools: ## Install build tools
	@echo "Installing tools: $(TOOLS)"
	@for tool in $(TOOLS); do asdf plugin add $$tool; asdf install $$tool; done
	@echo "Tools ready."

##@ Image targets

.PHONY: build
build: ## Build image
	DOCKER_BUILDKIT=1 DOCKER_CLI_HINTS=false docker build --platform $(PLATFORM) -t $(IMAGE):$(TAG) .
	docker tag $(IMAGE):$(TAG) $(IMAGE):latest

.PHONY: login
login: ## Login to OCI registry
	@echo $(GITHUB_TOKEN) | docker login ghcr.io -u $(GITHUB_USERNAME) --password-stdin

.PHONY: push
push: ## Push image to OCI registry
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):latest
