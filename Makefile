# Import Environment Variables

include .env


# Make Config

MAKEFLAGS   += --no-print-directory


# Docker Constants

IMAGE_NAME  := hashicorp/terraform
IMAGE_TAG   := 1.0.6
ENV_FILE    := ./.env
WORKING_DIR := /root/src


# Commands

.PHONY: init plan apply destroy

init:
	@ docker run --rm \
		-w $(WORKING_DIR) \
		-v $(CURDIR):$(WORKING_DIR) \
		$(IMAGE_NAME):$(IMAGE_TAG) init \
			-get=true \
			-backend=true \
			-backend-config="access_key=$(AWS_ACCESS_KEY)" \
			-backend-config="secret_key=$(AWS_SECRET_ACCESS_KEY)" \
			-backend-config="region=$(AWS_DEFAULT_REGION)" \
			-backend-config="bucket=$(AWS_S3_BUCKET)" \
			-backend-config="key=$(AWS_S3_KEY)"

plan:
	@ docker run --rm \
		-w $(WORKING_DIR) \
		-v $(CURDIR):$(WORKING_DIR) \
		--env-file $(ENV_FILE) \
		$(IMAGE_NAME):$(IMAGE_TAG) plan

apply:
	@ docker run --rm \
		-w $(WORKING_DIR) \
		-v $(CURDIR):$(WORKING_DIR) \
		--env-file $(ENV_FILE) \
		$(IMAGE_NAME):$(IMAGE_TAG) apply --auto-approve

destroy:
	@ docker run --rm \
		-w $(WORKING_DIR) \
		-v $(CURDIR):$(WORKING_DIR) \
		--env-file $(ENV_FILE) \
		$(IMAGE_NAME):$(IMAGE_TAG) destroy --auto-approve
