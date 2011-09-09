#!/bin/sh

REPOBASE=`readlink -f $1`
FROMTAG=$2
TOTAG=$3

TMPDIR=`mktemp -d`
PATCHFILE=$TMPDIR/libreoffice/libreoffice-build/patches/hotfixes/update-from-$FROMTAG-to-$TOTAG.diff
mkdir -p `dirname $PATCHFILE`

echo "commits from $FROMTAG to $TOTAG" > $PATCHFILE
for repo in \
    artwork \
    base \
    binfilter \
    bootstrap \
    calc \
    components \
    extensions \
    extras \
    filters \
    help \
    impress \
    libs-core \
    libs-extern \
    libs-extern-sys \
    libs-gui \
    postprocess \
    sdk \
    testing \
    translations \
    ure \
    writer
do
    if [ -d $REPOBASE/$repo.git ]
    then
        repodir=$REPOBASE/$repo.git
    elif [ -d $REPOBASE/$repo ]
    then
        repodir=$REPOBASE/$repo
    else
        exit 1
    fi
    #echo "commits on repository $repo from $FROMTAG to $TOTAG"
    git --git-dir=$repodir format-patch --stdout --subject-prefix="$repo" $FROMTAG..$TOTAG
done | sed \
    -e 's|^--- a/|--- |' \
    -e 's|^+++ b/|+++ |' \
>> $PATCHFILE

cd $TMPDIR && diff -u /dev/null libreoffice/libreoffice-build/patches/hotfixes/update-from-$FROMTAG-to-$TOTAG.diff
rm -rf $TMPDIR
