flush_unopkg_cache() {
	/usr/lib/openoffice/program/unopkg list --shared > /dev/null 2>&1
}

remove_extension() {
  if /usr/lib/openoffice/program/unopkg list --shared $1 >/dev/null; then
    INSTDIR=`mktemp -d`
    export PYTHONPATH="/@OOBASISDIR@/program"
    if [ -L /usr/lib/openoffice/basis-link ]; then
	d=/var/lib/openoffice/`readlink /usr/lib/openoffice/basis-link`/
    else
	d=/usr/lib/openoffice
    fi
    /usr/lib/openoffice/program/unopkg remove -v --shared $1 \
      "-env:UserInstallation=file://$INSTDIR" \
      "-env:UNO_JAVA_JFW_INSTALL_DATA=file://$d/share/config/javasettingsunopkginstall.xml" \
      "-env:JFW_PLUGIN_DO_NOT_CHECK_ACCESSIBILITY=1"
    if [ -n $INSTDIR ]; then rm -rf $INSTDIR; fi
    flush_unopkg_cache
  fi
}

validate_extensions() {
	/usr/lib/openoffice/program/unopkg validate -v --shared
}

sync_extensions() {
  if [ -e /usr/lib/openoffice/share/prereg/bundled ] && readlink /usr/lib/openoffice/share/prereg/bundled 2>&1 >/dev/null; then
    /usr/lib/openoffice/program/unopkg sync -v --shared \
      "-env:BUNDLED_EXTENSIONS_USER=file:///usr/lib/openoffice/share/prereg/bundled" \
      "-env:UserInstallation=file://$INSTDIR" \
      "-env:UNO_JAVA_JFW_INSTALL_DATA=file://$d/share/config/javasettingsunopkginstall.xml" \
      "-env:JFW_PLUGIN_DO_NOT_CHECK_ACCESSIBILITY=1"
  fi
}

