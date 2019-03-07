[![Build Status](https://travis-ci.com/scivision/lapack-cmake.svg?branch=master)](https://travis-ci.com/scivision/lapack-cmake)

# Lapack with cmake

A clean, robust FindLAPACK.cmake that works with Intel MKL or Netlib LAPACK for Fortran and LAPACKE (for C and C++)


## Example

```sh
cd build

cmake ..

cmake --build .

ctest -V
```


### Intel MKL

To verify Intel MKL was used, in general you can prefix the command you use to run a program with `MKL_VERBOSE=1` like:

```sh
MKLVERBOSE=1 ./build/svd_c
```
