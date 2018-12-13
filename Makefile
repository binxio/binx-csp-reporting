.PHONY: help deploy delete create-bucket lambda-package
.DEFAULT_GOAL := run

ENVIRONMENT = "binx"
BUCKET_NAME = "binx-csp-provider"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

deploy: create-bucket lambda-package ## create env
	@sceptre launch $(ENVIRONMENT)

delete: ## delete env
	@sceptre delete $(ENVIRONMENT)

create-bucket:
	@sceptre launch $(ENVIRONMENT)/eu/bucket.yaml

lambda-package:
	sam package \
		--template-file sam-templates/postreport.yaml \
		--output-template-file templates/postreport.yaml \
		--s3-bucket $(BUCKET_NAME)