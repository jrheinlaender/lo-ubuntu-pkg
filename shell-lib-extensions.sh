validate_extensions() {
  if /usr/lib/libreoffice/program/unopkg list --bundled >/dev/null 2>/dev/null; then
	/usr/lib/libreoffice/program/unopkg validate -v --bundled
  fi
}

sync_extensions() {
  INSTDIR=`mktemp -d`
  export PYTHONPATH="/@OODIR@/program"
  if [ -L /usr/lib/libreoffice/basis-link ]; then
	d=/var/lib/libreoffice/`readlink /usr/lib/libreoffice/basis-link`/
  else
	d=/usr/lib/libreoffice
  fi
  if [ -e /usr/lib/libreoffice/share/prereg/bundled ] && readlink /usr/lib/libreoffice/share/prereg/bundled 2>&1 >/dev/null && [ -e /usr/lib/libreoffice/program/unopkg.bin ]; then
      HOME=$INSTDIR \
        /usr/lib/libreoffice/program/unopkg sync -v --shared \
        "-env:BUNDLED_EXTENSIONS_USER=file:///usr/lib/libreoffice/share/prereg/bundled" \
        "-env:UserInstallation=file://$INSTDIR" \
        "-env:UNO_JAVA_JFW_INSTALL_DATA=file://$d/share/config/javasettingsunopkginstall.xml" \
        "-env:JFW_PLUGIN_DO_NOT_CHECK_ACCESSIBILITY=1"
      rm -rf $INSTDIR
  fi
}

