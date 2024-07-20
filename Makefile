all: build deploy

build:
	mix site.build

run:
	mix site.build
	open public/index.html

deploy:
	lftp -f upload.x
