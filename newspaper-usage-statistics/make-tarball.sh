#!/usr/bin/env bash

if [ -z $1 ]
then
  echo "usage: $0 folder"
  exit 1
fi

DIR=$1

if [ -e $DIR ]
then
  echo "$DIR already exists"
  exit 1
fi

mkdir $DIR
cp CHANGELOG.md README.md src/main/newspaper_statistics.py.cfg-example $DIR
cp -r src/main/scripts/statistics $DIR
tar czf $DIR.tgz $DIR
rm -rf $DIR
ls -l $DIR*


