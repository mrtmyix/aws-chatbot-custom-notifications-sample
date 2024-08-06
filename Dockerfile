# syntax=docker/dockerfile:1

ARG TERRAFORM_VERSION=1.9.3
FROM hashicorp/terraform:${TERRAFORM_VERSION} AS terraform

ENTRYPOINT ["/bin/sh"]
