#!/bin/sh

# where is Java? ;)
if [ -x /usr/lib/j2sdk1.3/bin/javac ]; then
	JDK_HOME=/usr/lib/j2sdk1.3
elif [ -x /usr/lib/j2se/1.3/bin/javac ]; then
	JDK_HOME=/usr/lib/j2se/1.3
else
	# uh oh, this isn't supposed to happen :)
	JDK_HOME=JDK_HOME_NOT_FOUND
fi

# write found value to stdout 
echo $JDK_HOME
