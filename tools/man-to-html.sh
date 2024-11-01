#!/bin/sh
cd $(dirname $0) || exit
cp ../man1/* ../man-html
cp ../man5/* ../man-html
cd ../man-html || exit
# These should be underlined in terminal, and rendered in monospace font
# on browsers.
sed -i 's|.I |.ft C|g' *1 *5
for man in check clean config find install remove snap upgrade ; do
cat sbo$man.1 | groff -mandoc -Thtml > sbo$man.html
done
cat sbotools.conf.5 | groff -mandoc -Thtml > sbotools.conf.5.html
rm *1 *5

sed -i 's|j@dawnrazor.net|j (at) dawnrazor (dot) net|g' *html
sed -i 's|xocel@iquidus.org|xocel (at) iquidus (dot) org|g' *html
sed -i 's|andreas.guldstrand@gmail.com|andreas (dot) guldstrand (at) gmail (dot) com|g' *html
sed -i 's|kvngncrlsn@gmail.com|kvngncrlsn (at) gmail (dot) com|g' *html
