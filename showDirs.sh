#!/bin/bash

function listFile() {
    if [ -r $1 ]; then
      echo -n `cat $1`
    else
      echo -n -e '   '
    fi
    echo -n -e ' \t'
}

function listName() {
    if [ -r $1 ]; then
      echo -n `basename $1`
    else
      echo -n -e '   '
    fi
    echo -n -e ' \t'
}


function listDir() {
  FILES="?1 ?2 ?3 ab ac bc abc"
  #echo "FILES: $FILES"
  for file in $FILES; do
    #echo "file: $file"
    fname=$1/${file}.txt
    listName $fname
  done
  echo ""
  for file in $FILES; do
    #echo "file: $file"
    fname=$1/${file}.txt
    listFile $fname
  done
  echo ""
  #ls $1
}

DIRS="dirA dirB dirD/dirC"

for dir in $DIRS; do
    echo ""
    echo $dir
    listDir $dir
done

echo ""
