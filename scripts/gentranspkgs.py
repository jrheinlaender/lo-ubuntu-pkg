#! /usr/bin/python

import re, sys, fileinput

skip_packages = ('openoffice.org-dbg')

def gen_transitonal_packages():
    skip = True
    copy_fields = ('Section', 'Architecture', 'Priority', 'Description')
    copy_fields = ('Section', 'Priority', 'Description')
    pkgs = {}
    for line in fileinput.input():
        if line == '\n':
            skip = True
        if ':' in line:
            f, v = line.split(':', 1)
            v = v.strip()
            if f == 'Package':
                if v.startswith('libreoffice'):
                    n = v.replace('libreoffice', 'openoffice.org')
                    p =  {'Depends': v}
                    pkgs[n] = p
                    skip = False
                else:
                    skip = True
            if not skip and f in copy_fields:
                p[f] = v
                
    for p, attrs in pkgs.iteritems():
        if p in skip_packages:
            continue
        print "Package: %s" % p
        print "Architecture: all"
        for f, v in attrs.items():
            if f in ('Depends', 'Description'):
                continue
            print "%s: %s" % (f, v)
        print "Depends: %s" % attrs['Depends']
        print "Description: %s" % attrs['Description']
        print " This is a transitional package, replacing the OpenOffice.org packaging"
        print " with the LibreOffice packaging."
        print " ."
        print " It can be safely removed after an upgrade."
        print

def main():
    gen_transitonal_packages()

main()
