check_for_running_ooo() {
	if [ -e /usr/lib/openoffice/program/bootstraprc ]; then
		LOCKFILE="`grep UserInstallation /usr/lib/openoffice/program/bootstraprc | cut -d= -f2 | sed -e 's,SYSUSERCONFIG,HOME,'`/.lock"
		PID=`pgrep soffice.bin | head -n 1`
		if [ -n "$PID" ] || [ -e "$LOCKFILE" ]; then
			if [ "$DEBIAN_FRONTEND" = "noninteractive" ]; then
				echo "OpenOffice.org running!" >&2
			 	echo "" >&2
				echo -n "OpenOffice.org is running right now with pid " >&2
				echo -n "$PID." >&2
				echo " This can cause problems" >&2
				echo "with (de-)registration of components and extensions" >&2
				echo "Thus this package will fail to install" >&2
				echo "You should close all running instances of OpenOffice.org (including" >&2
				echo "any currently running Quickstarter) before proceeding with the package" >&2
				echo "upgrade." >&2
				exit 1
			else
			  	db_input high shared/openofficeorg-running
			  	db_go
				# try again in case OOo got closed before hitting OK
				PID=`pgrep soffice.bin | head -n 1`
				if [ -n "$PID" ] || [ -e "$LOCKFILE" ]; then
			  		exit 1
				fi
			fi
		fi
	fi
}

handle_soffice_listeners() {
	services="docvert-converter"
	for s in $services; do
		if [ -x /etc/init.d/$s ]; then
			if [ -x /usr/sbin/invoke-rc.d ]; then
				invoke-rc.d $s $1
			else
				/etc/init.d/$s $1
			fi
		fi
	done
	# wait for proper shutdown/kill
	sleep 1
}

flush_unopkg_cache() {
	/usr/lib/openoffice/program/unopkg list --shared > /dev/null 2>&1
}

remove_extension() {
  handle_soffice_listeners stop
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
  handle_soffice_listeners start
}

add_extension() {
  handle_soffice_listeners stop
  check_for_running_ooo
  INSTDIR=`mktemp -d`
  export PYTHONPATH="/@OOBASISDIR@/program"
  basis=`readlink /usr/lib/openoffice/basis-link`
  /usr/lib/openoffice/program/unopkg add -v --shared $1 \
    "-env:UserInstallation=file:///$INSTDIR" \
    "-env:UNO_JAVA_JFW_INSTALL_DATA=file:///var/lib/openoffice/$basis/share/config/javasettingsunopkginstall.xml" \
    "-env:JFW_PLUGIN_DO_NOT_CHECK_ACCESSIBILITY=1"
  if [ -n $INSTDIR ]; then rm -rf $INSTDIR; fi
  handle_soffice_listeners start
}
