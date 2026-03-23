.PHONY: clean init main.tf

.DEFAULT_GOAL := plan

BINARY := terraform

clean:
	rm -rf main.tf

main.tf: $(shell find . -mindepth 2 -name "*.tf")
	@cat $^ > $@

init: clean main.tf
	$(BINARY) init

# when migrating Terraform provider versions
upgrade: clean main.tf
	$(BINARY) init -upgrade

# when migrating Terraform version
migrate: clean main.tf
	$(BINARY) init -migrate-state

plan: init
	$(BINARY) plan

apply: init
	$(BINARY) apply

validate:
	$(BINARY) validate
