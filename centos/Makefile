IMAGE_NAME := atsuio/rpmbuilder
LATEST := $(IMAGE_NAME):latest

.PHONY: keys build push

build: keys
	docker build -t $(IMAGE_NAME):centos6 -f 6/Dockerfile .
	docker build -t $(IMAGE_NAME):centos7 -t $(LATEST) -f 7/Dockerfile .
	docker build -t $(IMAGE_NAME):centos8 -f 8/Dockerfile .

keys:
	mkdir -p keys
	aws s3 cp s3://atsubuilds/RPM-GPG-KEY-atsu-release-latest keys/
	aws s3 cp s3://atsubuilds/RPM-GPG-KEY-atsu-release-previous keys/

push:
	docker push $(IMAGE_NAME):centos6
	docker push $(IMAGE_NAME):centos7
	docker push $(IMAGE_NAME):centos8
	docker push $(LATEST)

clean:
	rm -rf keys
