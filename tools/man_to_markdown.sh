#!/bin/sh

# Convert man pages to markdown; requires pandoc.

# This should be just about everything.

cd $(dirname $0) || exit
cp ../man1/* ../man-md
cp ../man5/* ../man-md
cd ../man-md || exit
for man in tools check clean config hints find install remove upgrade ; do
  cat sbo$man.1 | groff -mandoc -Thtml > sbo$man.1.html
done
cat sbotools.conf.5 | groff -mandoc -Thtml > sbotools.conf.5.html
cat sbotools.hints.5 | groff -mandoc -Thtml > sbotools.hints.5.html
rm *1 *5

# If something happens to me and someone else takes over the project,
# a word to the wise: Add your email address here.
sed -i 's|j@dawnrazor.net|j (at) dawnrazor (dot) net|g' *html
sed -i 's|xocel@iquidus.org|xocel (at) iquidus (dot) org|g' *html
sed -i 's|andreas.guldstrand@gmail.com|andreas (dot) guldstrand (at) gmail (dot) com|g' *html
sed -i 's|kvngncrlsn@gmail.com|kvngncrlsn (at) gmail (dot) com|g' *html

for man in tools check clean config hints find install remove upgrade ; do
  pandoc --from=html --to=markdown sbo$man.1.html > sbo$man.1.md
done

pandoc --from=html --to=markdown sbotools.conf.5.html > sbotools.conf.5.md
pandoc --from=html --to=markdown sbotools.hints.5.html > sbotools.hints.5.md

rm -f ./*html

# And now the fun part...
sed -i "s/#NAME/#name/g" *
sed -i "s/#SYNOPSIS/#synopsis/g" *
sed -i "s/#OPTIONS/#options/g" *
sed -i "s/#DESCRIPTION/#description/g" *
sed -i "s/#COMMANDS/#commands/g" *
sed -i "s/#STARTUP/#startup/g" *
sed -i "s/#BUGS/#bugs/g" *
sed -i "s/#SEE\%20ALSO/#see-also/g" *
sed -i "s/#EXIT\%20CODES/#exit-codes/g" *
sed -i "s/#VARIABLES/#variables/g" *
sed -i "s/#AUTHORS/#authors/g" *
sed -i 's|#MAINTAINER)\\|#maintainer)|g' *

sed -i "s/^## NAME.*/## NAME/g" *
sed -i "s/^## SYNOPSIS.*/## SYNOPSIS/g" *
sed -i "s/^## OPTIONS.*/## OPTIONS/g" *
sed -i "s/^## DESCRIPTION.*/## DESCRIPTION/g" *
sed -i "s/^## COMMANDS.*/## COMMANDS/g" *
sed -i "s/^## STARTUP.*/## STARTUP/g" *
sed -i "s/^## BUGS.*/## BUGS/g" *
sed -i "s/^## SEE ALSO.*/## SEE ALSO/g" *
sed -i "s/^## EXIT CODES.*/## EXIT CODES/g" *
sed -i "s/^## VARIABLES.*/## VARIABLES/g" *
sed -i "s/^## AUTHORS.*/## AUTHORS/g" *
sed -i "s/^## MAINTAINER.*/## MAINTAINER/g" *

for item in check clean config hints find install remove tools.conf tools.hints upgrade ; do
  sed -i "s/^# sbo$item.*/# sbo$item/g" *
done

sed -i "s/^# sbotools.*/# sbotools/g" sbotools.1.md

# Want man page links, but not bold ones.
for item in check clean config hints find install remove upgrade ; do
  sed -i "s/sbo$item(1)/[sbo$item(1)](sbo$item.1.md)/g" *
  sed -i "s/[*]\+\[sbo$item(1)\](sbo$item.1.md)[*]\+/[sbo$item(1)](sbo$item.1.md)/g" *
done

sed -i "s/sbotools.conf(5)/[sbotools.conf(5)](sbotools.conf.5.md)/g" *
sed -i "s/[*]\+\[sbotools.conf(5)\](sbotools.conf.5.md)[*]\+/[sbotools.conf(5)](sbotools.conf.5.md)/g" *

sed -i "s/sbotools.hints(5)/[sbotools.hints(5)](sbotools.hints.5.md)/g" *
sed -i "s/[*]\+\[sbotools.hints(5)\](sbotools.hints.5.md)[*]\+/[sbotools.hints(5)](sbotools.hints.5.md)/g" *

# Markdown doesn't like attempted links to rsync://
sed -i 's|<rsync://slackbuilds.org/slackbuilds>|rsync://slackbuilds.org/slackbuilds|g' *

# Right, time to work out code blocks.
for item in check clean config hints find install remove upgrade tools tools.hints ; do
  sed -i "s/^sbo$item/    sbo$item/g" *
  NUMCHAR=$(($(echo $item | wc -m)+7))
  SPACES=""
  X=0
  while [ $X -lt $NUMCHAR ] ; do
    SPACES="$SPACES "
    X=$((X+1))
  done
  [ -f sbo$item.1.md ] && sed -i "s/^\\\\\[/$SPACES\\\\[/g" sbo$item.1.md
  [ -f sbo$item.5.md ] && sed -i "s/^\\\\\[/$SPACES\\\\[/g" sbo$item.5.md
done

# Why, yes, these lines are horrible.
sed -i "s/\\\\\[/[/g" *
sed -i "s/\\\\\]/]/g" *
sed -i "s/^cd /    cd /g" *
sed -i "s/^!javacc/    !javacc /g" *
sed -i "s/^libcacard /    libcacard /g" *
sed -i 's|\\\\\\$|\\|g' *
sed -i "/^    /s/\\\|/|/g" *
sed -i "/^    /s/\\\-/-/g" *
sed -i "/^    /s/\\\\\\$/$/g" *
