# vim:set ai et sts=2 sw=2 tw=0:

# Query the terminal to establish a default number of columns to use for
# displaying messages to the user.  This is used only as a fallback in the
# event the COLUMNS variable is not set.  ($COLUMNS can react to SIGWINCH while
# the script is running, and this cannot, only being calculated once.)
DEFCOLUMNS=$(stty size 2> /dev/null | awk '{print $2}') || true
if ! expr "$DEFCOLUMNS" : "[[:digit:]]\+$" > /dev/null 2>&1; then
  DEFCOLUMNS=80
fi

if [ -e /usr/share/debconf/confmodule ]; then
	. /usr/share/debconf/confmodule
fi

message() {
	echo "$*" | fmt -t -w ${COLUMNS:-$DEFCOLUMNS} >&2
}

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

check_for_running_ooo() {
	if [ -e /usr/lib/openoffice/program/bootstraprc ]; then
		LOCKFILE=`grep UserInstallation /usr/lib/openoffice/program/bootstraprc | cut -d= -f2 | sed -e 's,SYSUSERCONFIG,HOME,'`
		if [ -x /usr/bin/pgrep ]; then
		  PID=`/usr/bin/pgrep soffice.bin | head -n 1`
		fi
		if [ -n "$PID" ] || [ -e "$LOCKFILE" ]; then
			db_input high openoffice.org/running
			db_go
			# try again in case OOo got closed before hitting OK
			if [ -x /usr/bin/pgrep ]; then
			  PID=`/usr/bin/pgrep soffice.bin | head -n 1`
 			fi
			if [ -n "$PID" ] || [ -e "$LOCKFILE" ]; then
			  exit 1
			fi
		fi
	fi
}

flush_unopkg_cache() {
	/usr/lib/openoffice/program/unopkg list --shared > /dev/null 2>&1
}

remove_extension() {
  check_for_running_ooo
  if /usr/lib/openoffice/program/unopkg list --shared $1 >/dev/null; then
    INSTDIR=`mktemp -d`
    export PYTHONPATH="/@OOBASISDIR@/program"
    basis=`readlink /usr/lib/openoffice/basis-link`
    /usr/lib/openoffice/program/unopkg remove -v --shared $1 \
      "-env:UserInstallation=file://$INSTDIR" \
      "-env:UNO_JAVA_JFW_INSTALL_DATA=file:///var/lib/openoffice/$basis/share/config/javasettingsunopkginstall.xml" \
      "-env:JFW_PLUGIN_DO_NOT_CHECK_ACCESSIBILITY=1"
    if [ -n $INSTDIR ]; then rm -rf $INSTDIR; fi
    flush_unopkg_cache
  fi
}

add_extension() {
  check_for_running_ooo
  INSTDIR=`mktemp -d`
  export PYTHONPATH="/@OOBASISDIR@/program"
  basis=`readlink /usr/lib/openoffice/basis-link`
  /usr/lib/openoffice/program/unopkg add -v --shared $1 \
    "-env:UserInstallation=file:///$INSTDIR" \
    "-env:UNO_JAVA_JFW_INSTALL_DATA=file:///var/lib/openoffice/$basis/share/config/javasettingsunopkginstall.xml" \
    "-env:JFW_PLUGIN_DO_NOT_CHECK_ACCESSIBILITY=1"
  if [ -n $INSTDIR ]; then rm -rf $INSTDIR; fi
}

revoke_from_services_rdb() {
  check_for_running_ooo
  rdb="`echo /@OOBASISDIR@/program | sed -e s/usr/var/`/services.rdb"
  lib="`basename $1`"
  if [ -e "$rdb" ] && /usr/lib/ure/bin/regview $rdb | grep -q $lib; then
    /usr/lib/ure/bin/regcomp -revoke -r $rdb -br $rdb -c file://$1
  fi
}

register_to_services_rdb() {
  check_for_running_ooo
  rdb="`echo /@OOBASISDIR@/program | sed -e s/usr/var/`/services.rdb"
  /usr/lib/ure/bin/regcomp -register -r $rdb -br $rdb -c file://$1
}

VER=

