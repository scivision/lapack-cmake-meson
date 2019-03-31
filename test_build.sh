#!/bin/bash

cd "${0%/*}"  # change to directory of this script

fc=$1

bindir=build

for cc in gcc clang pgcc icc
do

[[ $(which $cc) ]] || continue

rm -r $bindir/CMakeCache.txt

CC=$cc cmake -B $bindir -S .

[[ $? == 0 ]] && cmake --build $bindir

[[ $? == 0 ]] && (cd $bindir; ctest)

done

rm -r $bindir/CMakeCache.txt
