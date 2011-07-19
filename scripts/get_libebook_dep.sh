#!/bin/sh

libs=`grep -o libebook.*\.so.[0-9]* build/connectivity/source/drivers/evoab2/EApi.cxx`
for l in $libs; do
	echo "Testing candidate library $l" >&2
	libdir=/usr/lib
	if [ `dpkg-architecture -qDEB_BUILD_ARCH` = "amd64" ]; then
		libdir=/usr/lib`dpkg-architecture -qDEB_BUILD_ARCH_BITS`
	fi
	if [ -e "$libdir/$l" ]; then
		# sanity check: do the libs match with what we would get
		# for our libebook version if we followed the .so symlink?
		l1=`readlink $libdir/$l`
		l2_tmp=`echo $l | grep -o libebook.*\.so`
		l2=`readlink $libdir/$l2_tmp`
		if [ "$l1" = "$l2" ]; then
			dep=`dpkg -S $l1 | cut -d: -f1`
			# exit on success, we want the first (highest matching) API version
			echo $dep
			exit 0
		else
			echo "$l failed sanity check, because $l1 is not $l2." >&2
		fi
	fi
done

echo "Cannot find libebook dependency. None of the following libs found:" >&2
echo $libs >&2
exit 1
