# vim:set ai et sts=2 sw=2 tw=0:

trap "message;\
      message \"Received signal.  Aborting script $0.\";\
      message;\
      exit 1" 1 2 3 15

# call hook in openoffice.org-debian-files
if [ -x /usr/share/openoffice.org-debian-files/install-hook ]; then
  /usr/share/openoffice.org-debian-files/install-hook $THIS_SCRIPT $THIS_PACKAGE "$@"
fi

# old hook - DEPRECIATED
if [ -x /usr/lib/openoffice.org-debian-files/install-hook ]; then
  /usr/lib/openoffice.org-debian-files/install-hook $THIS_SCRIPT $THIS_PACKAGE "$@"
fi

#DEBHELPER#

