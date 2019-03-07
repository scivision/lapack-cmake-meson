[![Build Status](https://travis-ci.com/scivision/lapack-cmake.svg?branch=master)](https://travis-ci.com/scivision/lapack-cmake)

# Lapack with cmake

A clean, modern FindLAPACK.cmake that works with Intel MKL or Netlib LAPACK for Fortran and LAPACKE (for C and C++).
Uses PkgConfig in CMake to making finding Lapack / LapackE on Linux, MacOS and Windows more robust.

## prereq

* Linux: `apt install liblapacke-dev`
* Mac: `brew install lapack` doesn't currently include LapackE, so you'd need to compile [Lapack from source](https://github.com/Reference-LAPACK/lapack)
* Windows: compile [Lapack from source](https://github.com/Reference-LAPACK/lapack), or use [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).


## Example

```sh
cd build

cmake ..

cmake --build .

ctest -V
```


### Intel MKL

To verify
[Intel MKL](https://software.intel.com/en-us/mkl)
was used, in general you can prefix the command you use to run a program with `MKL_VERBOSE=1` like:

```sh
MKLVERBOSE=1 ./build/svd_c
```
