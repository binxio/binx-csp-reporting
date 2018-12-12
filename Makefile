.PHONY: help init clean validate mock create delete info deploy
.DEFAULT_GOAL := run

environment = "binx/dev/eu-west-1"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create: merge-swagger environments/$(ENVIRONMENT).yaml ## create env
	@sceptre launch-env $(environment)

delete: ## delete env
	@sceptre delete-env $(environment)

info: ## describe resources
	@sceptre describe-env-resources $(environment)
	@sceptre describe-stack-outputs $(environment) bucket

deploy: delete create info ## delete and create

merge-swagger: lint-swagger ## merged swagger with api gateway
	@aws-cfn-update \
		rest-api-body  \
		--resource RestAPI \
		--open-api-specification swagger/swagger.yaml \
		--add-new-version \
		templates/platform/api.yaml

lint-swagger: ## lint the swagger.yaml spec
	openapi-spec-validator --schema 2.0 swagger.yaml

lambda-build-zip: ## create a lambda archive
	./update_version.sh
	docker build -t my-lambda .

lambda-dist: lambda-build-zip ## create a new lambda.zip in 'dist' directory
	mkdir -p dist
	./copy_from_docker.sh
	unzip -l dist/lambda.zip

lambda-upload-zip: ## upload lambda.zip to environment needs ENVIRONMENT=st
	aws s3 cp dist/lambda.zip s3://ocp-lambda-$(ENVIRONMENT)/lambda.zip --profile ocp-$(ENVIRONMENT)

lambda-clean: ## clean artifact
	-rm -rf dist