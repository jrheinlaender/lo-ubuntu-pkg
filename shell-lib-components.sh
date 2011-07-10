revoke_all_components_from_services_rdb() {
    for lib in /@OOBASISDIR@/registered-components/*.so; do
	if [ -e "$lib" ]; then
	    revoke_from_services_rdb "$(readlink -f "$lib")"
	fi
    done
}

register_all_components_to_services_rdb() {
    for lib in /@OOBASISDIR@/registered-components/*.so; do
	if [ -e "$lib" ]; then
	    register_to_services_rdb "$(readlink -f "$lib")"
	fi
    done
}

revoke_from_services_rdb() {
  if [ "$THIS_PACKAGE" != "libreoffice-core" ]; then
      status=$(dpkg-query -W -f='${status}' libreoffice-core|cut -d ' ' -f3)
      if [ "$status" != "installed" ]; then
	  echo "skipping revoke because of unconfigured libreoffice-core"
	  return
      fi
  fi
  rdb="`echo /@OOBASISDIR@/program | sed -e s/usr/var/`/services.rdb"
  lib="`basename $1`"
  if [ -e "$rdb" ] && /usr/lib/ure/bin/regview $rdb | grep -q $lib; then
    /usr/lib/ure/bin/regcomp -revoke -r $rdb -br $rdb -c file://$1
  fi
}

register_to_services_rdb() {
  if [ "$THIS_PACKAGE" != "libreoffice-core" ]; then
      status=$(dpkg-query -W -f='${status}' libreoffice-core|cut -d ' ' -f3)
      if [ "$status" != "installed" ]; then
	  echo "skipping register because of unconfigured libreoffice-core"
	  return
      fi
  fi
  rdb="`echo /@OOBASISDIR@/program | sed -e s/usr/var/`/services.rdb"
  /usr/lib/ure/bin/regcomp -register -r $rdb -br $rdb -c file://$1
}

update_services_rdb() {
	if [ -f /@OOBASISDIR@/program/.services.rdb ]; then
		echo "Updating services.rdb..."
		rdb="`echo /@OOBASISDIR@/program | sed -e s/usr/var/`/services.rdb"
		if [ -d /@OOBASISDIR@/registered-components ]; then
			cat /@OOBASISDIR@/program/.services.rdb \
				| sed -e "s#</components>##" \
				> $rdb
			for c in /@OOBASISDIR@/registered-components/*.component; do \
				tail -n 1 $c \
				| sed -e 's#<component xmlns="http://openoffice.org/2010/uno-components"#<component#'\
				>> $rdb; \
			done
			perl -pi -e "s/\n//" $rdb
			sed -i 's#$#</components>#' $rdb
		else
			cp /@OOBASISDIR@/program/.services.rdb $rdb
		fi
		echo "done."
	fi
}
