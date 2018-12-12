.PHONY: help deploy delete merge-swagger lint-swagger lambda-package
.DEFAULT_GOAL := run

ENVIRONMENT = "binx/dev/eu-west-1"
BUCKET_NAME = "binx-csp-provider"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

deploy: lambda-package merge-swagger ## create env
	@sceptre launch-env $(ENVIRONMENT)

delete: ## delete env
	@sceptre delete-env $(ENVIRONMENT)

merge-swagger: lint-swagger ## merged swagger with api gateway
	@aws-cfn-update \
		rest-api-body  \
		--resource RestAPI \
		--open-api-specification swagger/swagger.yaml \
		--add-new-version \
		templates/platform/api.yaml

lint-swagger: ## lint the swagger.yaml spec
	openapi-spec-validator --schema 2.0 swagger.yaml

lambda-package:
	sam package \
		--template-file sam-templates/postreport.yaml \
		--output-template-file templates/postreport.yaml \
		--s3-bucket $(BUCKET_NAME)