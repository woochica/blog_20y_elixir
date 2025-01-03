all: build deploy

dev:
	MIX_ENV=dev mix site.build
	open public/index.html

deploy-bits:
	emacs -Q --batch --eval "(progn (require 'ox-publish) (org-publish-file \"/home/slink/Documents/slinkbook/bits.org\" '(\"slinkbook\" :base-directory \"/home/slink/Documents/slinkbook\" :publishing-directory \"/home/slink/Documents/20y.hu/public\")))"
	lftp -f upload.x

deploy:
	MIX_ENV=prod mix site.build
	emacs -Q --batch --eval "(progn (require 'ox-publish) (org-publish-file \"/home/slink/Documents/slinkbook/bits.org\" '(\"slinkbook\" :base-directory \"/home/slink/Documents/slinkbook\" :publishing-directory \"/home/slink/Documents/20y.hu/public\")))"
	lftp -f upload.x
