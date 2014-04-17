#!/bin/sh

if [ ! $1 ]; then
  pkgdir=`julia -e 'println(Pkg.dir())'`
else
  pkgdir=$1
fi

path=$pkgdir/JuliaTest/julie

for rc in  ~/.bashrc ~/.zshrc; do
  if [ -f $rc ]; then
    if [ ! "`grep 'alias julie' $rc`" ]; then
      echo "alias julie=$path" >> $rc
    fi
  fi
done

source ~/.`basename $SHELL`rc

