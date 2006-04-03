#! /usr/bin/python

import os
import sys
from translate.storage import oo

def statistics(mf):
    helpfiles = [fn for fn in mf.listsubfiles() if fn.startswith('helpcontent2')]
    #print helpfiles
    n_all = n_translated = n_untranslated = 0
    for helpfile in helpfiles:
        of = mf.getoofile(helpfile)
        #print helpfile, of.languages, len(of.ooelements)
        for el in of.ooelements:
            n_all += 1
            if len(el.lines) == 1:
                #print "WARNING: %s: no translation (%d lines)" % (helpfile, len(el.lines))
                n_untranslated += 1
                continue
            if len(el.lines) > 2:
                print "WARNING: %s: too many translations (%d lines)" % (helpfile, len(el.lines))
                continue
            if el.lines[0].text == el.lines[1].text \
               and el.lines[0].helptext == el.lines[1].helptext \
               and el.lines[0].quickhelptext == el.lines[1].quickhelptext:
                pass
                #print "Not translated: %s/%s/%s" % (el.lines[0].text, el.lines[0].helptext, el.lines[0].quickhelptext)
                #print "                %s/%s/%s" % (el.lines[1].text, el.lines[1].helptext, el.lines[1].quickhelptext)
            else:
                n_translated += 1
    return n_all, n_translated, n_untranslated

if __name__ == '__main__':
    for fn in sys.argv[1:]:
        #sys.stderr.write("loading %s ...\n" % fn)
	#sys.stderr.flush()
        try:
            mf = oo.oomultifile(fn)
        except Exception, msg:
            sys.stdout.write("ERROR reading %s: %s\n" % (fn, msg))
	    sys.stdout.flush()
        all, translated, untranslated = statistics(mf)
        try:
            ratio = translated / float(all) * 100
        except:
            ratio = 0.0
        print "%15s: %4.1f%%, lines=%d, translated=%d, untranslated=%d" % (os.path.basename(fn), ratio, all, translated, untranslated)
	sys.stdout.flush()
