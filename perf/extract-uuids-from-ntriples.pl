#!/usr/bin/env perl -l

use 5.010;
use diagnostics;
use strict;

# <info:fedora/uuid:543b1b5e-383e-453c-bfdf-426be46efb04> <info:fedora/fedora-system:def/model#hasModel> <info:fedora/doms:ContentModel_EditionPage> .

while (<>) {
    if (/<info:fedora\/(uuid:[0-9a-z\-]+)>/) {
        print "$1";
    }
}
