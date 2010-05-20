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

add_extension() {
  INSTDIR=`mktemp -d`
  export PYTHONPATH="/@OOBASISDIR@/program"
  if [ -L /usr/lib/openoffice/basis-link ]; then
      d=/var/lib/openoffice/`readlink /usr/lib/openoffice/basis-link`/
  else
      d=/usr/lib/openoffice
  fi
  /usr/lib/openoffice/program/unopkg add -v --shared $1 \
    "-env:UserInstallation=file:///$INSTDIR" \
    "-env:UNO_JAVA_JFW_INSTALL_DATA=file://$d/share/config/javasettingsunopkginstall.xml" \
    "-env:JFW_PLUGIN_DO_NOT_CHECK_ACCESSIBILITY=1"
  if [ -n $INSTDIR ]; then rm -rf $INSTDIR; fi
}
