#!/bin/sh

cd "${0%/*}"  # change to directory of this script


for cc in gcc /usr/bin/clang pgcc icc
do

touch build/junk
rm -r build/*

CC=$cc cmake -B build -S .
cmake --build build

done
