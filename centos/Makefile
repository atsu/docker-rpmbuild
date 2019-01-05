IMAGE_NAME := atsuio/rpmbuilder
LATEST := $(IMAGE_NAME):latest

.PHONY: build push

build: 
	docker build -t $(IMAGE_NAME):centos6 -f 6/Dockerfile .
	docker build -t $(IMAGE_NAME):centos7 -t $(LATEST) -f 7/Dockerfile .

push:
	docker push $(IMAGE_NAME):centos6
	docker push $(IMAGE_NAME):centos7
	docker push $(LATEST)