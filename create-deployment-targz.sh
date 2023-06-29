#!/usr/bin/env bash

set -e

DIR=newspaper-fastcgi-ticket-checker-$(grep -m 1 -o "^[0-9.]\+" CHANGELOG.md)

mkdir -p tmp
tar cvzf tmp/${DIR}.tgz "--transform=s_^_${DIR}/_" CHANGELOG.md fcgid-access-checker/

