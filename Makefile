
DOCKER_CMD = sudo docker
DOCKER_BUILDER = mabuilder

NAME = minio-python-sample
DOCKER_IMAGE = minio-python-sample
DOCKER_IMAGE_VERSION = 1.0.0
IMAGE_NAME = $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)
REGISTRY_SERVER = docker.io
REGISTRY_LIBRARY = yasuhiroabe

PROD_IMAGE_NAME = $(REGISTRY_SERVER)/$(REGISTRY_LIBRARY)/$(IMAGE_NAME)

.PHONY: all build build-prod tag push run stop check

all:
	@echo "Please specify a target: make [run|docker-build|docker-build-prod|docker-push|docker-run|docker-stop|check|clean]"

run: bundle-install
	env FORM_BASEURI="$(PROTOCOL)://$(HOST):$(PORT)/$(URI_PATH)" \
		bundle exec rackup --host $(HOST) --port $(PORT)

bundle-install:
	bundle config set path lib
	bundle install

docker-build:
	$(DOCKER_CMD) build . --tag $(DOCKER_IMAGE):latest

docker-build-prod:
	$(DOCKER_CMD) build . --tag $(IMAGE_NAME) --no-cache

docker-tag:
	$(DOCKER_CMD) tag $(IMAGE_NAME) $(PROD_IMAGE_NAME)

docker-push:
	$(DOCKER_CMD) push $(PROD_IMAGE_NAME)

docker-run:
	$(DOCKER_CMD) run -it --rm -d \
		--env NGINX_PORT=80 \
		-p 8080:80 \
		-v `pwd`/html:/usr/share/nginx/html \
		--name $(NAME) \
                $(DOCKER_IMAGE):latest

docker-stop:
	$(DOCKER_CMD) stop $(NAME)

clean:
	find . -name '*~' -type f -exec rm {} \; -print

.PHONY: docker-buildx-init
docker-buildx-init:
	$(DOCKER_CMD) buildx create --name $(DOCKER_BUILDER) --use

.PHONY: docker-buildx-setup
docker-buildx-setup:
	$(DOCKER_CMD) buildx use $(DOCKER_BUILDER)
	$(DOCKER_CMD) buildx inspect --bootstrap

.PHONY: docker-buildx-prod
docker-buildx-prod:
	$(DOCKER_CMD) buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --tag $(PROD_IMAGE_NAME) --no-cache --push .

.PHONY: docker-runx
docker-runx:
	$(DOCKER_CMD) run -it --rm  \
		--env LC_CTYPE=ja_JP.UTF-8 \
		-p $(PORT):8080 \
		--name $(NAME) \
		$(PROD_IMAGE_NAME)
