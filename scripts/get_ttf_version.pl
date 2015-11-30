#!/usr/bin/perl

# derived from http://cgit.freedesktop.org/libreoffice/core/diff/solenv/bin/modules/installer/windows/file.pm?id=38e24f1d059a6123ea15a68b4b24ca984642d66e
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This file incorporates work covered by the following license notice:
#
#   Licensed to the Apache Software Foundation (ASF) under one or more
#   contributor license agreements. See the NOTICE file distributed
#   with this work for additional information regarding copyright
#   ownership. The ASF licenses this file to you under the Apache
#   License, Version 2.0 (the "License"); you may not use this file
#   except in compliance with the License. You may obtain a copy of
#   the License at http://www.apache.org/licenses/LICENSE-2.0 .

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
