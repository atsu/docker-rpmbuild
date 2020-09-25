build:
	make -C centos

test:
	bats **/**/*.bats

push:
	make -C centos push
