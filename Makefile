.PHONY: build
MAKEFLAGS += --silent

default: echo

ZATO_VERSION=3.2

ZATO_ANSIBLE_DIR=$(CURDIR)/zato-ansible
ZATO_ANSIBLE_QS_DIR=$(ZATO_ANSIBLE_DIR)/quickstart

ZATO_GHCR_USER=vinixsatria
ZATO_GHCR_TOKEN=GfY6wjVwhEhDrlcFvL2Fl8ogrhcsew1GouuL
ZATO_DOCKER_HUB_USER=kemenkesri

PARENT_IMAGE_DIR=$(CURDIR)/parent
QUICKSTART_IMAGE_DIR=$(CURDIR)/quickstart

parent-build:
	cp $(ZATO_ANSIBLE_QS_DIR)/*.yaml $(PARENT_IMAGE_DIR)
	cd $(PARENT_IMAGE_DIR)
	DOCKER_BUILDKIT=1 docker build --no-cache -t zato-$(ZATO_VERSION)-minimal-parent $(PARENT_IMAGE_DIR)
	docker tag zato-$(ZATO_VERSION)-minimal-parent:latest ghcr.io/kemkes/zato-$(ZATO_VERSION)-minimal-parent:latest
	cd $(CURDIR)

parent-push:
	docker login ghcr.io -u $(ZATO_GHCR_USER) -p ghp_$(ZATO_GHCR_TOKEN)
	docker push ghcr.io/kemkes/zato-$(ZATO_VERSION)-minimal-parent:latest
	cd $(CURDIR)

parent-all:
	$(MAKE) parent-build
	$(MAKE) parent-push

quickstart-build:
	cp $(ZATO_ANSIBLE_QS_DIR)/* $(QUICKSTART_IMAGE_DIR)
	cd $(QUICKSTART_IMAGE_DIR)
	DOCKER_BUILDKIT=1 docker build --no-cache -t zato-$(ZATO_VERSION)-minimal $(QUICKSTART_IMAGE_DIR)
	docker tag zato-$(ZATO_VERSION)-minimal:latest ghcr.io/kemkes/zato-$(ZATO_VERSION)-minimal:latest
	cd $(CURDIR)

dockerhub-push:
	echo $(ZATO_DOCKER_HUB_TOKEN) | docker login -u $(ZATO_DOCKER_HUB_USER) -p SatuSehat@kemenkesRI
	docker tag zato-$(ZATO_VERSION)-minimal kemenkesri/zato-$(ZATO_VERSION)-minimal
	docker push kemenkesri/zato-$(ZATO_VERSION)-minimal

github-push:
	echo $(ZATO_GHCR_TOKEN) | docker login ghcr.io -u $(ZATO_GHCR_USER) -p ghp_$(ZATO_GHCR_TOKEN)
	docker push ghcr.io/kemkes/zato-$(ZATO_VERSION)-minimal:latest
	cd $(CURDIR)

all-build-push:
	~/clean.sh || true
	$(MAKE) parent-all
	$(MAKE) quickstart-build
	$(MAKE) dockerhub-push
	$(MAKE) github-push

echo:
	echo Hello from zato-docker
