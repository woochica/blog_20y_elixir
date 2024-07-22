all: build deploy

dev:
	MIX_ENV=dev mix site.build
	open public/index.html

deploy:
	MIX_ENV=prod mix site.build
	lftp -f upload.x
