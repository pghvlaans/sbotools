#!/bin/bash

# Make sbotools.tar and put it in the root sbotools directory
# for submission to SBo.

# Run only after the new version has been uploaded to the website.

# Requires sbo-maintainer-tools.

SBOROOT="$(pwd)"
PWB="$(basename "$SBOROOT")"

if [ ! -d "./man1" ] || [ "$PWB" != "sbotools" ] || [ ! -d "./slackbuild/sbotools" ]; then
  echo "Run make_sbo_tarball.sh from the root sbotools directory."
  exit 1
fi

TEMPDIR=$(mktemp -d)

if [ ! -d "$TEMPDIR" ]; then
  echo "Making the temporary directory failed. Exiting."
  exit 1
fi

(
  cd "$TEMPDIR" || exit 1
  cp -r "$SBOROOT/slackbuild/sbotools" .
  if [ ! -d sbotools ]; then
    echo "Copying the SlackBuild directory failed. Exiting."
    exit 1
  fi
  rm -f sbotools/*.tar.gz
  source ./sbotools/sbotools.info || exit 1
  wget $DOWNLOAD || exit 1
  NEW_MD5SUM="$(md5sum "sbotools-$VERSION.tar.gz" | awk '{print $1}')"
  sed -i "s/@MD5@/$NEW_MD5SUM/g" sbotools/sbotools.info || exit 1
  sed -i 's|_pghv|_SBo|g' sbotools/sbotools.SlackBuild || exit 1
  sed -i 's|/tmp/pghv|/tmp/SBo|g' sbotools/sbotools.SlackBuild || exit 1

  sbolint sbotools
  tar cavf sbotools.tar sbotools/
)

cp "$TEMPDIR/sbotools.tar" .
rm -r "$TEMPDIR"

echo ""
echo "Created sbotools.tar and moved it to the sbotools directory."
