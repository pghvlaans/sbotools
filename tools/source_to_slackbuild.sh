#!/bin/bash

# Make sbotools-*.tar.gz and put it in the slackbuild/sbotools
# directory to build a packge.

SBOROOT="$(pwd)"
PWB="$(basename "$SBOROOT")"

if [ ! -d "./man1" ] || [ "$PWB" != "sbotools" ] || [ ! -d "./slackbuild/sbotools" ]; then
  echo "Run source_to_slackbuild.sh from the root sbotools directory."
  exit 1
fi

VER=$(awk '/^SBO-Lib version/{print $3}' SBO-Lib/README)
TEMPDIR=$(mktemp -d)

if [ ! -d "$TEMPDIR" ]; then
  echo "Making the temporary directory failed. Exiting."
  exit 1
fi

(
  cd "$TEMPDIR" || exit 1
  cp -r "$SBOROOT" "sbotools-$VER"
  if [ ! -d "sbotools-$VER" ]; then
    echo "Copying the sbotools directory failed. Exiting."
    exit 1
  fi
  rm -rf "sbotools-$VER/.git"
  rm -f sbotools-"$VER"/slackbuild/sbotools/*.tar.gz
  tar cavf "sbotools-$VER.tar.gz" "sbotools-$VER/"
)

cp "$TEMPDIR/sbotools-$VER.tar.gz" slackbuild/sbotools
rm -r "$TEMPDIR"

echo ""
echo "Created sbotools-$VER.tar.gz and moved it to slackbuild/sbotools."
