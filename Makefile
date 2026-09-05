# soul-ssh-vault — an SshProvider, NOT a SoulModule, and the gate differs because of it.
#
# A SoulModule's schema document is GENERATED from its Go value and `soul-mod stamp`
# is what proves the two agree. This artifact serves `kind: ssh_provider`: it has no
# `schema` subcommand — running the binary starts the provider — and its
# schema.json is HAND-MAINTAINED. So the check here is `soul-lint validate-manifest`,
# the same one soul-stack's lint loop ran over examples/module/*/schema.json before
# this repository existed (NIM-825). Nothing regenerates the document; if you edit
# params_schema, edit the file.
.DEFAULT_GOAL := help

BIN       := soul-ssh-vault
SOUL_LINT ?= soul-lint

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | \
	  awk 'BEGIN{FS=":.*?## "}{printf "%-18s %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the artifact into dist/
	GOWORK=off go build -o dist/$(BIN) .

.PHONY: test
test: ## Unit tests with the race detector
	GOWORK=off go test -race ./...

.PHONY: vet
vet: ## go vet
	GOWORK=off go vet ./...

.PHONY: fmt
fmt: ## Refuse unformatted sources
	@out=$$(GOWORK=off gofmt -l .); \
	  if [ -n "$$out" ]; then echo "gofmt: $$out" >&2; exit 1; fi

.PHONY: no-replace
no-replace: ## Refuse a `replace` in go.mod — it would re-couple this repo to a soul-stack checkout
	@if grep -q '^replace' go.mod; then \
	  echo "go.mod carries a replace directive. This repository depends on the core through" >&2; \
	  echo "published sdk/proto-plugin versions only (ADR-011); a replace makes it buildable" >&2; \
	  echo "only next to a soul-stack checkout, which is what moving it here undid." >&2; \
	  exit 1; \
	fi
	@echo "no-replace: go.mod depends on published versions only"

.PHONY: manifest
manifest: ## schema.json is a valid ssh_provider document
	@command -v $(SOUL_LINT) >/dev/null 2>&1 || { \
	  echo "$(SOUL_LINT) not on PATH. This gate needs the linter from the core repo:" >&2; \
	  echo "  go build -o /usr/local/bin/soul-lint ./soul-lint/cmd/soul-lint  (in soul-stack)" >&2; \
	  echo "  or: make manifest SOUL_LINT=/path/to/soul-lint" >&2; exit 1; }
	@$(SOUL_LINT) validate-manifest schema.json

.PHONY: check
check: fmt vet no-replace test manifest ## The whole gate
	@echo "check: green"
