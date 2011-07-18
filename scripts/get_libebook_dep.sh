#!/bin/sh

libs=`grep -o libebook.*\.so build/connectivity/source/drivers/evoab2/EApi.cxx|sort|uniq`
for l in $libs; do
	echo "Testing candidate library $l" >&2
	if [ -e "/usr/lib/$l" ]; then
		# sanity check: do the libs match with what we would get
		# for our libebook version if we followed the .so symlink?
		l1=`readlink /usr/lib/$l`
		l2_tmp=`echo $l | perl -pe 's/(.*)\.\d+$/$1/'`
		l2=`readlink /usr/lib/$l2_tmp`
		if [ "$l1" = "$l2" ]; then
			dep=`dpkg -S /usr/lib/$l | cut -d: -f1`
		else
			echo "$l failed sanity check, because $l1 is not $l2." >&2
		fi
	fi
done

if [ -n "$dep" ]; then
	echo $dep
else
	echo "Cannot find libebook dependency. None of the following libs found:" >&2
	echo $libs >&2
	exit 1
fi

