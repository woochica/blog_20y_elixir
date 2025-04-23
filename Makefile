all: build deploy

BLOG20Y_TARGET=/home/slink/Documents/20y.hu/public

dev:
	BLOG20Y_TARGET=${BLOG20Y_TARGET} MIX_ENV=dev mix site.build
	open ${BLOG20Y_TARGET}/index.html

deploy-bits:
	emacs -Q --batch --eval "(progn (require 'ox-publish) (org-publish-file \"/home/slink/Documents/slinkbook/bits.org\" '(\"slinkbook\" :base-directory \"/home/slink/Documents/slinkbook\" :publishing-directory \"${BLOG20Y_TARGET}\")))"
	lftp -f upload.x

deploy:
	BLOG20Y_TARGET=${BLOG20Y_TARGET} MIX_ENV=prod mix site.build
	emacs -Q --batch --eval "(progn (require 'ox-publish) (org-publish-file \"/home/slink/Documents/slinkbook/bits.org\" '(\"slinkbook\" :base-directory \"/home/slink/Documents/slinkbook\" :publishing-directory \"${BLOG20Y_TARGET}\")))"
	lftp -f upload.x
