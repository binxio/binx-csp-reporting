.PHONY: help deploy delete create-bucket build package
.DEFAULT_GOAL := run

ENVIRONMENT = "binx"
BUCKET_NAME = "binx-csp-provider"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

deploy: build package
	@sceptre launch $(ENVIRONMENT)

delete: ## delete env
	@sceptre delete $(ENVIRONMENT)

create-bucket:
	@sceptre launch $(ENVIRONMENT)/eu/bucket.yaml

build:
	sam build \
		-s lambdas/ \
		-t sam-templates/postreport.yaml \
		-m lambdas/requirements.txt \
		--use-container

package:
	sam package \
		--output-template-file templates/postreport.yaml \
		--s3-bucket $(BUCKET_NAME)