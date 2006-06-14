#! /usr/bin/python

import sys, fileinput

def splitlines():
    fields = ('Build-Depends', 'Build-Conflicts', 'Depends', 'Replaces',
              'Provides', 'Conflicts', 'Recommends', 'Suggests')
    for line in fileinput.input():
        line = line[:-1]
        field = None
        for f in fields:
            if line.startswith(f+':'):
                field = f
                break
        if not field:
            print line
            continue
        values = [f.strip() for f in line.split(':',1)[1].strip().split(',')]
        if len(values) > 2:
            print '%s: %s' % (field, ',\n '.join(values))
        else:
            print '%s: %s' % (field, ', '.join(values))

    
def main():
    splitlines()

main()
