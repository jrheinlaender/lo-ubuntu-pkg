# vim:set ai et sts=2 sw=2 tw=0:

trap "message;\
      message \"Received signal.  Aborting script $0.\";\
      message;\
      exit 1" 1 2 3 15

# call hook in openoffice.org-debian-files
HOOKFILE=/usr/lib/openoffice.org-debian-files/install-hook

if [ -x $HOOKFILE ]; then
  $HOOKFILE  $THIS_PACKAGE $THIS_SCRIPT "$@"
fi

#DEBHELPER#

