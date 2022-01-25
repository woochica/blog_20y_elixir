.PHONY:	build

build:
	HUGO_ENV=production hugo --gc --minify
	mv public/post/index.html public/journal/
	mv public/post/index.xml public/journal/

run:
	hugo server -D
