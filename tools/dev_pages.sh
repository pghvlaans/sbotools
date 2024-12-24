#!/bin/sh

# Generate SBO::Lib::*.3 pages. Pass --all to generate all
# pages, or the names of one or more individual modules.

if ! [[ -d "./man3" ]]; then
	echo "you do not seem to be at the right place to run this."
	echo "the man3/ directory should be under ."
	exit 1
fi

if [[ -z $1 ]]; then
  echo "Usage: e.g., ./tools/dev_pages.sh Build Tree"
  echo "Usage:       ./tools/dev_pages.sh --all"
  exit 1
fi

# Note that this will take today's ddate and the version
# in Lib.pm.

version=$(grep '^our $VERSION' SBO-Lib/lib/SBO/Lib.pm | grep -Eo '[0-9]+(\.[0-9RC@gita-f]+){0,2}')
datestring="$(ddate +"%{%A, %B %d%}, %Y YOLD%N - %H")"
cd SBO-Lib/lib || exit
if [[ $1 = '--all' ]]; then
  for item in Build Download Info Pkgs Readme Repo Tree Util ; do
    pod2man -r "" -c "sbotools $version" -d "$datestring" SBO/Lib/$item.pm ../../man3/SBO::Lib::$item.3
  done
  exit
fi

while [[ -n $@ ]]; do
  if [[ -f SBO/Lib/$1.pm ]]; then
    pod2man -r "" -c "sbotools $version" -d "$datestring" SBO/Lib/$1.pm ../../man3/SBO::Lib::$1.3
  else
    echo "The file $1.pm does not exist. Skipping."
  fi
  shift
done
