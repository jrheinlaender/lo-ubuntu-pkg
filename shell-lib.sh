# vim:set ai et sts=2 sw=2 tw=0:

trap "message;\
      message \"Received signal.  Aborting $THIS_PACKAGE package $THIS_SCRIPT script.\";\
      message;\
      exit 1" 1 2 3 15

message () {
  # pretty-print messages of arbitrary length
  echo "$*" | fold -s -w ${COLUMNS:-80} >&2;
}

message_nonl () {
  # pretty-print messages of arbitrary length (no trailing newline)
  echo -n "$*" | fold -s -w ${COLUMNS:-80} >&2;
}

errormsg () {
  # exit script with error
  message "$*"
  exit 1;
}

internal_errormsg() {
  # exit script with error; essentially a "THIS SHOULD NEVER HAPPEN" message
  message "$*"
  message "Please report the package name, version, and the text of the" \
          "above error message(s) to <debian-x@lists.debian.org>.";
  exit 1;
}

maplink () {
  # returns what symlink should point to; i.e., what the "sane" answer is
  # Keep this in sync with the debian/*.links files.
  # This is only needed for symlinks to directories.
  case "$1" in
    /etc/X11/xkb/compiled) echo /var/lib/xkb ;;
    /etc/X11/xkb/xkbcomp) echo /usr/X11R6/bin/xkbcomp ;;
    /usr/X11R6/lib/X11/app-defaults) echo /etc/X11/app-defaults ;;
    /usr/X11R6/lib/X11/fs) echo /etc/X11/fs ;;
    /usr/X11R6/lib/X11/lbxproxy) echo /etc/X11/lbxproxy ;;
    /usr/X11R6/lib/X11/proxymngr) echo /etc/X11/proxymngr ;;
    /usr/X11R6/lib/X11/rstart) echo /etc/X11/rstart ;;
    /usr/X11R6/lib/X11/twm) echo /etc/X11/twm ;;
    /usr/X11R6/lib/X11/xdm) echo /etc/X11/xdm ;;
    /usr/X11R6/lib/X11/xinit) echo /etc/X11/xinit ;;
    /usr/X11R6/lib/X11/xkb) echo /etc/X11/xkb ;;
    /usr/X11R6/lib/X11/xserver) echo /etc/X11/xserver ;;
    /usr/X11R6/lib/X11/xsm) echo /etc/X11/xsm ;;
    /usr/bin/X11) echo ../X11R6/bin ;;
    /usr/bin/rstartd) echo ../X11R6/bin/rstartd ;;
    /usr/include/X11) echo ../X11R6/include/X11 ;;
    /usr/lib/X11) echo ../X11R6/lib/X11 ;;
    *) internal_errormsg "ERROR: maplink() called with unknown path \"$1\"" ;;
  esac;
}

analyze_path () {
  # given a supplied set of pathnames, break each one up by directory and do an
  # ls -dl on each component, cumulatively; i.e.
  # analyze_path /usr/X11R6/bin -> ls -dl /usr /usr/X11R6 /usrX11R6/bin
  # Thanks to Randolph Chung for this clever hack.
  while [ -n "$1" ]; do
    G=
    message "Analyzing $1:"
    for F in $(echo "$1" | tr / \  ); do
      if [ -e /$G$F ]; then
        ls -dl /$G$F >&2
        G=$G$F/
      else
        message "/$G$F: nonexistent"
        break
      fi
    done
    shift
  done
}

if ! command -v readlink > /dev/null 2>&1; then
  message "The readlink command was not found.  Please install version" \
          "1.13.1 or later of the debianutils package."
  readlink () {
    # returns what symlink in $1 actually points to
    perl -e '$l = shift; exit 1 unless -l $l; $r = readlink $l; exit 1 unless $r; print "$r\n"' $1;
  }
fi

check_symlinks_and_warn () {
  # for each argument, checks for symlink sanity, and warns if they aren't sane
  # should be called from preinst scripts only
  if [ -n "$*" ]; then
    for SYMLINK in $*; do
      if [ -L $SYMLINK ]; then
        if [ "$(maplink $SYMLINK)" != "$(readlink $SYMLINK)" ]; then
          message "Warning: $SYMLINK symbolic link points to the wrong" \
                  "place.  Removing."
          rm $SYMLINK
        fi
      elif [ -e $SYMLINK ]; then
        ERRMSG="ERROR: $SYMLINK exists and is not a symbolic link.  "
        ERRMSG="${ERRMSG}This package cannot be installed until this"
        if [ -f $SYMLINK ]; then
          ERRMSG="$ERRMSG file"
        elif [ -d $SYMLINK ]; then
          ERRMSG="$ERRMSG directory"
        else
          ERRMSG="$ERRMSG thing"
        fi
        ERRMSG="$ERRMSG is removed."
        message "$ERRMSG"
        errormsg "Aborting installation of $THIS_PACKAGE package."
      fi
    done
  else
    internal_errormsg "Argh.  Some chucklehead called" \
                      "check_symlinks_and_warn() with no arguments."
  fi;
}

check_symlinks_and_bomb () {
  # for each argument, checks for symlink sanity, and bombs if they aren't sane
  # should be called from postinst scripts only
  if [ -n "$*" ]; then
    for SYMLINK in $*; do
      if [ -L $SYMLINK ]; then
        if [ "$(maplink $SYMLINK)" != "$(readlink $SYMLINK)" ]; then
          analyze_path $SYMLINK $(readlink $SYMLINK)
          internal_errormsg "ERROR: $SYMLINK symbolic link points to the" \
                            "wrong place.  This should have been fixed by" \
                            "the package preinst script."
        fi
      elif [ -e $SYMLINK ]; then
        analyze_path $SYMLINK $(readlink $SYMLINK)
        internal_errormsg "ERROR: $SYMLINK is not a symbolic link. " \
                          "The package preinst script should have failed."
      else
        analyze_path $SYMLINK $(readlink $SYMLINK)
        internal_errormsg "ERROR: $SYMLINK symbolic link does not exist. " \
                          "Either the package didn't ship the symbolic link" \
                          "(a bug in the package), or dpkg failed to unpack" \
                          "it to the filesystem (a bug in dpkg)."
      fi
    done
  else
    internal_errormsg "Argh.  Some chucklehead called" \
                      "check_symlinks_and_bomb() with no arguments."
  fi;
}
