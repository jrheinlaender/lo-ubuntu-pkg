# vim:set ai et sts=2 sw=2 tw=0:

# Query the terminal to establish a default number of columns to use for
# displaying messages to the user.  This is used only as a fallback in the
# event the COLUMNS variable is not set.  ($COLUMNS can react to SIGWINCH while
# the script is running, and this cannot, only being calculated once.)
DEFCOLUMNS=$(stty size 2> /dev/null | awk '{print $2}') || true
if ! expr "$DEFCOLUMNS" : "[[:digit:]]\+$" > /dev/null 2>&1; then
  DEFCOLUMNS=80
fi

message() {
	echo "$*" | fmt -t -w ${COLUMNS:-$DEFCOLUMNS} >&2
}

trap "message;\
      message \"Received signal.  Aborting script $0.\";\
      message;\
      exit 1" 1 2 3 15

VER=2

# call hook in openoffice.org-debian-files
if [ -x /usr/share/openoffice.org${VER}-debian-files/install-hook ]; then
  /usr/share/openoffice.org${VER}-debian-files/install-hook $THIS_SCRIPT $THIS_PACKAGE "$@"
fi

#DEBHELPER#

