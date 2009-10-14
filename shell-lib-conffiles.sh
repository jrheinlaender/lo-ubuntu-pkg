# Prepare to move a conffile without triggering a dpkg question
prep_rm_conffile() {
    CONFFILE="$1"

    if [ -e "$CONFFILE" ]; then
        md5sum="`md5sum \"$CONFFILE\" | sed -e \"s/ .*//\"`"
        old_md5sum="`dpkg-query -W -f='${Conffiles}' $2 | grep $CONFFILE | awk '{print $2}'`"
        if [ "$md5sum" = "$old_md5sum" ]; then
            mv "$CONFFILE" "$CONFFILE.${THIS_PACKAGE}-tmp"
        fi
    fi
}

rm_conffile_commit() {
  CONFFILE="$1"

  if [ -e $CONFFILE.${THIS_PACKAGE}-tmp ]; then
    rm $CONFFILE.${THIS_PACKAGE}-tmp
  fi
}

# Remove a no-longer used conffile
rm_conffile() {
    CONFFILE="$1"

    if [ -e "$CONFFILE" ]; then
        md5sum="`md5sum \"$CONFFILE\" | sed -e \"s/ .*//\"`"
        old_md5sum="`dpkg-query -W -f='${Conffiles}' $2 | grep $CONFFILE | awk '{print $2}'`"
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
