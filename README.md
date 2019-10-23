[![Build Status](https://travis-ci.com/scivision/lapack-cmake.svg?branch=master)](https://travis-ci.com/scivision/lapack-cmake)

# Lapack with Meson or CMake

A clean, modern
[FindLAPACK.cmake](./cmake/Modules/FindLAPACK.cmake)
with verified compatibility across a wide range of compilers, operating systems and Lapack vendors.
Optionally, uses PkgConfig in CMake to make finding Lapack / LapackE more robust.


## CMake

Here is a brief listing of known working configurations:

Windows:

Compiler | Lapack
---------|-------
MSVC 15 2017 | Intel MKL
PGI | Intel MKL


Linux:

Compiler | Lapack
---------|-------
gcc + gfortran | Netlib Lapack
gcc + gfortran | Intel MKL
gcc + gfortran | Atlas
gcc + gfortran | OpenBLAS
Clang + gfortran  | Netlib Lapack
Clang + gfortran  | Intel MKL
Clang + gfortran  | Atlas
Clang + gfortran  | OpenBLAS
Clang + Flang | Netlib Lapack
Clang + Flang | Intel MKL
Clang + Flang | Atlas
Clang + Flang  | OpenBLAS

### Example

This example is for SVD computation using LapackE from C.

For most non-MSVC compilers (e.g. GNU, PGI, Clang, etc.):

```sh
cd build

cmake ..

cmake --build .

ctest -V
```

If you have a Fortran compiler, a Fortran Lapack example will also be built and tested.


For MSVC compilers, only the C example is built, and requires Intel MKL:

```sh
cmake -G "Visual Studio 16 2019" -B build

cmake --build build
```

## Meson

Lapack with Meson works with similar compiler configurations as CMake.

```sh
meson build

meson test -C build
```

to use MKL with Meson, do like

```sh
meson build -DMKL_ROOT=$MKLROOT  # linux
```


## prereq

* Linux: `apt install liblapacke-dev`
* Mac: `brew install lapack`
* Windows: compile [Lapack from source](https://github.com/Reference-LAPACK/lapack), or use [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).


### Intel MKL

Intel MKL is automatically detected by if
[`MKLROOT` environment variable is set](https://software.intel.com/en-us/mkl-windows-developer-guide-checking-your-installation).
This variable should be set BEFORE using CMake as proscribed by Intel for your operating system, typically by running `mklvars` script.
Here I assume you've installed MKL as appropriate for the
[MKL directory structure](https://software.intel.com/en-us/mkl-windows-developer-guide-high-level-directory-structure).

The command used to activate Intel MKL for each Terminal / Command Prompt session is like:

* Linux: `source ~/intel/mkl/bin/mklvars.sh intel64`
* Mac: `source ~/intel/mkl/bin/mklvars.sh intel64`
* Windows: `c:\"Program Files (x86)"\IntelSWTools\compilers_and_libraries\windows\mkl\bin\mklvars.bat intel64`

You need to do this EVERY TIME you want to use MKL for the Terminal / Command Prompt, or run it automatically at startup.
What we usually do is create a script in the home directory that simply runs that command when called.

To verify
[Intel MKL](https://software.intel.com/en-us/mkl)
was used, run a program with `MKL_VERBOSE=1` like:

* Mac / Linux: `MKL_VERBOSE=1 ./build/svd_c`
* Windows:

    ```posh
    set MKL_VERBOSE=1

    build\c_src\Debug\svd_c
    ```

#### Windows

* On Windows, MinGW is not supported with MKL at least through MKL 2019--you will get all kinds of errors.
* Windows CMake systems that don't want to use MSVC must in general include `cmake -G "MinGW Makefiles"` along with their other options.
  This is true for anything CMake is used for on Windows where Visual Studio is not wanted.

### MKL + PGI on Windows

Assuming you have already set `CC=pgcc` `CXX=pgc++` and `FC=pgfortran`, this will work with MKL for C and Fortran using the
[free PGI Community Edition compilers](https://www.scivision.dev/install-pgi-free-compiler/)

```sh
python build.py pgi
```


