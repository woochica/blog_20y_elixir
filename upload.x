open -u gabor@20y.hu -p 21 okcynm.loginssl.com
set ftp:use-mdtm off
mirror --only-newer --delete --reverse ~/Documents/20y.hu/public /public_html/~slink
put .htaccess -o /public_html/
exit
