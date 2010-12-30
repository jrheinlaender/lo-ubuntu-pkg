#! /usr/bin/python

import sys, fileinput

def splitlines():
    fields = ('Build-Depends', 'Build-Conflicts', 'Build-Depends-Indep', 'Depends', 'Replaces',
              'Provides', 'Conflicts', 'Recommends', 'Suggests')
    fields = ('Build-Depends', 'Build-Conflicts', 'Build-Depends-Indep')
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

    
def joinlines():
    fields = ('Build-Depends', 'Build-Conflicts', 'Build-Depends-Indep', 'Depends', 'Replaces',
              'Provides', 'Conflicts', 'Recommends', 'Suggests')
    buffer = None
    for line in fileinput.input():
        line = line[:-1]
        if buffer:
            if line.startswith(' '):
                buffer = buffer + ' ' + line.strip()
                continue
            else:
                print buffer
                buffer = None
        field = None
        for f in fields:
            if line.startswith(f+':'):
                field = f
                break
        if field:
            buffer = line.strip()
            continue
        print line

def main():
    if len(sys.argv) > 1 and sys.argv[1] in ('-s', '--split'):
        del sys.argv[1]
        splitlines()
    else:
        joinlines()

main()
