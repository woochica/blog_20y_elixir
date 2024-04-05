.PHONY:	build

build:
	HUGO_ENV=production hugo --gc --minify

run:
	hugo server -D &
	open http://localhost:1313/~slink/
