#!/bin/bash

set -e

cc=$1
fc=$2

cd "${0%/*}"  # change to directory of this script

. ~/intel.sh  # source mklvars.sh

bindir=build

rm -f $bindir/CMakeCache.txt

CC=$cc FC=$fc cmake -B $bindir

cmake --build $bindir

(cd $bindir; ctest -V)
