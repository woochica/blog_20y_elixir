all: build deploy

build:
	HUGO_ENV=production hugo --gc --minify

run:
	hugo server -D &
	open http://localhost:1313/~slink/

deploy:
	lftp -f upload.x
