#!/bin/bash

cd "${0%/*}"  # change to directory of this script

fc=$1

bindir=build

for cc in gcc clang pgcc icc icl
do

[[ $(which $cc) ]] || continue

rm -f $bindir/CMakeCache.txt

CC=$cc ctest -S setup.cmake -VV

done

rm -f $bindir/CMakeCache.txt
