.PHONY:	build

build:
	HUGO_ENV=production hugo --gc --minify

run:
	hugo server -D
