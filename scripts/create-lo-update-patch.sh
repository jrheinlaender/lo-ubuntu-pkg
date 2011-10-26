#!/bin/bash

REPOBASE=`readlink -f $1`
FROMTAG=$2
TOTAG=$3

TMPDIR=`mktemp -d`
PATCHFILE=$TMPDIR/libreoffice/libreoffice-build/patches/hotfixes/update-from-$FROMTAG-to-$TOTAG.diff
mkdir -p `dirname $PATCHFILE`

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
    ure \
    writer
do
    TAGPREFIX=
    if [[ "$repo" == "binfilter" ]]
    then
        TAGPREFIX="${repo}_"
    fi
    if [[ -d $REPOBASE/$repo.git ]]
    then
        repodir=$REPOBASE/$repo.git
    elif [[ -d $REPOBASE/$repo ]]
    then
        repodir=$REPOBASE/$repo
    else
        exit 1
    fi

    MERGEBASE=`cd $repodir && git merge-base ${TAGPREFIX}${FROMTAG} ${TAGPREFIX}${TOTAG}`
    echo "reverting on repository $repo from ${FROMTAG} to merge-base ${MERGEBASE}"
    git --git-dir=$repodir diff ${TAGPREFIX}${FROMTAG}..${MERGEBASE}
    echo "commits on repository $repo merge-base ${MERGEBASE} to ${TOTAG}"
    git --git-dir=$repodir format-patch --stdout --subject-prefix="$repo" ${MERGEBASE}..${TAGPREFIX}${TOTAG}
done | sed \
    -e 's|^--- a/|--- |' \
    -e 's|^+++ b/|+++ |' \
>> $PATCHFILE

cd $TMPDIR && diff -u /dev/null libreoffice/libreoffice-build/patches/hotfixes/update-from-$FROMTAG-to-$TOTAG.diff
rm -rf $TMPDIR
