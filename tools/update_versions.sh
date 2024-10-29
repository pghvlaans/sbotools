#!/bin/sh

usage_exit() {
	echo "Usage: $(basename $0) (-g) version"
	exit 1
}

if [[ "$1" == "" ]]; then
	usage_exit
fi

if [[ "$1" == "-?" ]]; then
	usage_exit
fi

if [[ "$1" == "-h" ]]; then
	usage_exit
fi

if [[ "$1" == "-g" ]]; then
	git=true
	shift
fi

if [[ "$1" == "" ]]; then
	usage_exit
fi

version="$1"

update_perl="
	SBO3-Lib/lib/SBO3/Lib.pm
	SBO3-Lib/lib/SBO3/Lib/Util.pm
	SBO3-Lib/lib/SBO3/Lib/Tree.pm
	SBO3-Lib/lib/SBO3/Lib/Repo.pm
	SBO3-Lib/lib/SBO3/Lib/Readme.pm
	SBO3-Lib/lib/SBO3/Lib/Pkgs.pm
	SBO3-Lib/lib/SBO3/Lib/Info.pm
	SBO3-Lib/lib/SBO3/Lib/Download.pm
	SBO3-Lib/lib/SBO3/Lib/Build.pm
  SBO3-Lib/lib/SBO3/App.pm
  SBO3-Lib/lib/SBO3/App/Remove.pm
  SBO3-Lib/lib/SBO3/App/Snap.pm
"
update_other="
  SBO3-Lib/README
	slackbuild/sbotools/sbotools.SlackBuild
	slackbuild/sbotools/sbotools.info
"

old_version=$(grep '^our $VERSION' SBO3-Lib/lib/SBO3/Lib.pm | grep -Eo '[0-9]+(\.[0-9RC@gita-f]+){0,1}')

tmpfile=$(mktemp /tmp/XXXXXXXXXX)

for i in $update_other; do
	cat $i | sed "s/$old_version/$version/g" > $tmpfile
	if [[ "$?" == "0" ]]; then
		mv $tmpfile $i
	fi
done

for i in $update_perl; do
  cat $i | sed "s/'$old_version'/'$version'/g" > $tmpfile
  if [[ "$?" == "0" ]]; then
    mv $tmpfile $i
  fi
done
