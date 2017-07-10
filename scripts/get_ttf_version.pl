#!/usr/bin/perl

# derived from http://cgit.freedesktop.org/libreoffice/core/diff/solenv/bin/modules/installer/windows/file.pm?id=38e24f1d059a6123ea15a68b4b24ca984642d66e
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

open (TTF, "<$ARGV[0]") or die "could not open ttf";
binmode TTF;
{local $/ = undef; $ttfdata = <TTF>;}
close TTF;

my $ttfversion = "(Version )([0-9]+[.]*([0-9][.])*[0-9]+)";

if ($ttfdata =~ /$ttfversion/ms)
{
    my ($version, $subversion, $microversion, $vervariant) = split(/\./,$2);
        $fileversion = int($version) . "." . int($subversion);
}

print $fileversion;
