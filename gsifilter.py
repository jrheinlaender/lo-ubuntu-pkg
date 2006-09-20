#! /usr/bin/python

import os
import sys
from translate.storage import oo

debug = False

def dupfilter(mf, comment, fn):
    n_all = n_translated = n_untranslated = n_same = 0
    new_sources = []
    for oofile in mf.listsubfiles():
        of = mf.getoofile(oofile)
        if oofile.startswith('helpcontent2'):
            try:
                elements = of.ooelements
            except:
                elements = of.units
            for el in elements:
                n_all += 1
                if len(el.lines) == 1:
                    if debug:
                        print "WARNING: %s: no translation (%d lines)" % (helpfile, len(el.lines))
                    n_untranslated += 1
                    continue
                if len(el.lines) > 2:
                    if debug:
                        print "WARNING: %s: too many translations (%d lines)" % (helpfile, len(el.lines))
                        print "   ", el.lines[0].project, el.lines[0].sourcefile, el.lines[0].groupid,el.lines[0].localid
                    continue
                if el.lines[0].text == el.lines[1].text \
                   and el.lines[0].helptext == el.lines[1].helptext \
                   and el.lines[0].quickhelptext == el.lines[1].quickhelptext:
                    n_same += 1
                    if debug:
                        print "Not translated: %s/%s/%s" % (el.lines[0].text, el.lines[0].helptext, el.lines[0].quickhelptext)
                        print "                %s/%s/%s" % (el.lines[1].text, el.lines[1].helptext, el.lines[1].quickhelptext)
                    el.lines = [line for line in el.lines if line.languageid == "en-US"]
                else:
                    n_translated += 1
        new_sources.append(str(of))

    try:
        ratio = n_translated / float(n_all) * 100
    except:
        ratio = 0.0
    print "%s: %15s: %4.1f%%, lines=%5d, translated=%5d, untranslated=%5d, same=%5d" \
          % (comment, os.path.basename(fn), ratio, n_all, n_translated, n_untranslated, n_same)
    print "\tremoved %d translations with same text" % n_same
    sys.stdout.flush()

    return ''.join(new_sources)

if __name__ == '__main__':
    for fn in sys.argv[1:]:
        try:
            mf = oo.oomultifile(fn)
        except Exception, msg:
            sys.stdout.write("ERROR reading %s: %s\n" % (fn, msg))
	    sys.stdout.flush()
            sys.exit(1)

        filtered = dupfilter(mf, "help", fn)

        fd = file(fn + '.tmp', 'w')
        fd.write(filtered)
        fd.close()
