#!/bin/sh

usage_exit() {
	echo "Usage: $(basename $0) (-d)"
	exit 1
}

if [[ "$1" == "-h" ]]; then
	usage_exit
fi

if [[ "$1" == "-?" ]]; then
	usage_exit
fi

if [[ "$1" == "-d" ]]; then
	date=true
	shift
fi

version=$(grep '^our $VERSION' SBO-Lib/lib/SBO/Lib.pm | grep -Eo '[0-9]+(\.[0-9RC@gita-f]+){0,2}')

if ! [[ -d "./man1" ]]; then
	echo "you do not seem to be at the right place to run this."
	echo "the man{1,5}/ directories should be under ."
	exit 1
fi

old_version=$(head -1 man1/sbocheck.1 | rev | cut -d' ' -f2 | rev \
	| sed 's/"//g')

tmpfile=$(mktemp /tmp/XXXXXXXXX)

sed_file() {
	if [[ "$1" == "" || "$2" == "" ]]; then
		echo "sed_file(): two arguments required."
		exit 1
	fi

	file="$1"
	sed_cmd="$2"

	cat $file | sed "$sed_cmd" > $tmpfile
	if [[ "$?" == "0" ]]; then
		mv $tmpfile $file
	else
		return 1
	fi

	return 0
}

for i in $(ls man1); do
	sed_file man1/$i "s/$old_version/$version/g"
done

for i in $(ls man5); do
	sed_file man5/$i "s/$old_version/$version/g"
done

if [[ "$?" == "0" ]]; then
	echo "version updated."
fi

update_date() {
	if ! which ddate >/dev/null 2>&1; then
		echo "I can't find ddate."
		return 1
	fi

	old_date="$(head -1 man1/sbocheck.1 | cut -d' ' -f4- | rev \
		| cut -d' ' -f4- | rev | sed 's/"//g')"

	new_date="$(ddate +"%{%A, %B %d%}, %Y YOLD%N - %H")"

	for i in man1/*; do
		sed_file $i "s/$old_date/$new_date/g"
	done

	for i in man5/*; do
		sed_file $i "s/$old_date/$new_date/g"
	done

	if [[ "$?" == "0" ]]; then
		echo "date updated."
	else
		return 1
	fi

	return 0
}

date_return=0
if [[ "$date" == "true" ]]; then
	update_date
	date_return=$?
fi

if [[ "$date_return" != "0" ]]; then
	exit 1
fi

# Regenerate the man3 pages, just in case.
sh tools/dev_pages.sh --all

exit 0
