PROJ := atdyn-dev
REPO := docker-image-redmine
VER := $(shell cat VERSION)

build:
	docker build --tag=gcr.io/$(PROJ)/$(REPO) .
	docker build --tag=gcr.io/$(PROJ)/$(REPO):$(VER) .

push:
	gcloud docker -- push gcr.io/$(PROJ)/$(REPO):$(VER)
	gcloud docker -- push gcr.io/$(PROJ)/$(REPO):latest
