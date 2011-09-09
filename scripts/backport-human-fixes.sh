#!/bin/bash
# A short script to create an tarball with the updated ooo_custom_images/human icons for the 3.4 branch
COREREPO=`readlink -f $1`
OUTFILE=`readlink -f $2`
`cd ${COREREPO} && git checkout e05ccb1672505c16825833ea628e2e82c6b544c0`
TOUCHEDFILES=`cd ${COREREPO} && git diff --name-only libreoffice-3.4.2.3..e05ccb1672505c16825833ea628e2e82c6b544c0 -- ooo_custom_images/human`
PACKDIR=`mktemp -d`
for file in ${TOUCHEDFILES}
do
    mkdir -p `dirname ${PACKDIR}/ext-human-updates/${file}`
    cp -p ${COREREPO}/${file} ${PACKDIR}/ext-human-updates/${file}
done
tar --create --gzip --verbose --file ${OUTFILE} --directory ${PACKDIR} .
rm -rf ${PACKDIR}
