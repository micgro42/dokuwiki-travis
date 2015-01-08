#!/usr/bin/sh
#
# This script sets up a DokuWiki environment to run the plugin's tests on
# travis-ci.org. The plugin itself will be moved to its correct location within
# the DokiWiki hierarchy.
#
# @author Andreas Gohr <andi@splitbrain.org>

# make sure this runs on travis only
if [ -z "$TRAVIS" ]; then
    echo 'This script is only intended to run on travis-ci.org build servers'
    exit 1
fi

# check we're in the right working directory and have tests
if [ ! -d '_test' ]; then
    echo 'No _test directory found, script was probably called from the wrong working directory'
    exit 1
fi

# find out where this plugin belongs to
BASE=`awk '/^base/{print $2}' plugin.info.txt`
if [ -z "$BASE" ]; then
    echo 'This plugins misses a base entry in plugin.info.txt'
    exit 1
fi

# remove current .git
rm -rf .git

# move everything to the correct location
echo ">MOVING TO: lib/plugins/$BASE"
mkdir -p lib/plugins/$BASE
mv {*,.*} lib/plugins/$BASE/ 2>/dev/null

# checkout DokuWiki into current directory (no clone because dir isn't empty)
# the branch is specified in the $DOKUWIKI environment variable
echo ">CLONING DOKUWIKI: $DOKUWIKI"
git init
git pull https://github.com/splitbrain/dokuwiki.git $DOKUWIKI

# install additional requirements
REQUIRE="lib/plugins/$BASE/requirements.txt"
if [ -f "$REQUIRE" ]; then
    grep -v '^#' "$REQUIRE" | \
    while read -r LINE
    do
        if [ ! -z "$LINE" ]; then
            echo ">REQUIREMENT: $LINE"
            git clone $LINE
        fi
    done
fi

# we now have a full dokuwiki environment with our plugin installed
# travis can take over
exit 0
