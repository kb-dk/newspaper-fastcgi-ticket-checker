#!/usr/bin/env bash

set -e

DIR=newspaper-fastcgi-ticket-checker-$(head -n 1 CHANGELOG.md)

mkdir -p tmp
tar cvzf tmp/${DIR}.tgz "--transform=s_^_${DIR}/_" CHANGELOG.md fcgid-access-checker/

