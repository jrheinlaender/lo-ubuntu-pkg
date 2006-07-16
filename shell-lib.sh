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

# Prepare to move a conffile without triggering a dpkg question
prep_mv_conffile() {
    CONFFILE="$1"

    if [ -e "$CONFFILE" ]; then
        md5sum="`md5sum \"$CONFFILE\" | sed -e \"s/ .*//\"`"
        old_md5sum="`sed -n -e \"/^Conffiles:/,/^[^ ]/{\\\\' $CONFFILE'{s/.* //;p}}\" /var/lib/dpkg/status`"
        if [ "$md5sum" = "$old_md5sum" ]; then
            rm -f "$CONFFILE"
        fi
    fi
}

# Remove a no-longer used conffile
rm_conffile() {
    CONFFILE="$1"

    if [ -e "$CONFFILE" ]; then
        md5sum="`md5sum \"$CONFFILE\" | sed -e \"s/ .*//\"`"
        old_md5sum="`sed -n -e \"/^Conffiles:/,/^[^ ]/{\\\\' $CONFFILE'{s/.* //;p}}\" /var/lib/dpkg/status`"
        if [ "$md5sum" != "$old_md5sum" ]; then
            echo "Obsolete conffile $CONFFILE has been modified by you."
            echo "Saving as $CONFFILE.dpkg-bak ..."
            mv -f "$CONFFILE" "$CONFFILE".bak
        else
            echo "Removing obsolete conffile $CONFFILE ..."
            rm -f "$CONFFILE"
        fi
    fi
}

# Move a conffile without triggering a dpkg question
mv_conffile() {
    OLDCONFFILE="$1"
    NEWCONFFILE="$2"

    if [ -e "$OLDCONFFILE" ]; then
        echo "Preserving user changes to $NEWCONFFILE ..."
        mv -f "$NEWCONFFILE" "$NEWCONFFILE".dpkg-new
        mv -f "$OLDCONFFILE" "$NEWCONFFILE"
    fi
}

trap "message;\
      message \"Received signal.  Aborting script $0.\";\
      message;\
      exit 1" 1 2 3 15

VER=

