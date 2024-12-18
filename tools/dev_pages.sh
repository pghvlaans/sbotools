#!/bin/sh

# Generate the SBO::Lib::*.3 pages.

if ! [[ -d "./man3" ]]; then
	echo "you do not seem to be at the right place to run this."
	echo "the man3/ directory should be under ."
	exit 1
fi

# Note that this will take today's ddate and the version
# in Lib.pm.

version=$(grep '^our $VERSION' SBO-Lib/lib/SBO/Lib.pm | grep -Eo '[0-9]+(\.[0-9RC@gita-f]+){0,1}')
datestring="$(ddate +"%{%A, %B %d%}, %Y YOLD%N - %H")"

cd SBO-Lib/lib || exit
for item in Build Download Info Pkgs Readme Repo Tree Util ; do
  pod2man -r "" -c "sbotools $version" -d "$datestring" SBO/Lib/$item.pm ../../man3/SBO::Lib::$item.3
done
