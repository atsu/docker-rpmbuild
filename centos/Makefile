IMAGE_NAME := ghcr.io/atsu/rpmbuilder
LATEST := $(IMAGE_NAME):latest

.PHONY: keys build push

build: keys
	docker build -t $(IMAGE_NAME):centos6 -f 6/Dockerfile .
	docker build -t $(IMAGE_NAME):centos7 -t $(LATEST) -f 7/Dockerfile .

keys:
	mkdir -p keys

push:
	docker push $(IMAGE_NAME):centos6
	docker push $(IMAGE_NAME):centos7
	docker push $(LATEST)

clean:
	rm -rf keys
