test:
	bats **/**/*.bats
	
build:
	make -C centos

push:
	make -C centos push
