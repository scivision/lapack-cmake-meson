# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:

FindLapack
----------

* Michael Hirsch, Ph.D. www.scivision.dev
* David Eklund

Let Michael know if there are more MKL / Lapack / compiler combination you want.
Refer to https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor

Finds LAPACK and LapackE libraries.
Works with Netlib Lapack and Intel MKL,
including for non-Intel compilers with Intel MKL.
Intel MKL relies on having environment variable MKLROOT set, typically by sourcing
mklvars.sh beforehand.

Why not the FindLapack.cmake built into CMake? It has a lot of old code for
infrequently used Lapack libraries and is unreliable for me.

Tested with Netlib Lapack and Intel MKL on Linux, MacOS and Windows with:
* GCC / Gfortran
* Clang / Flang
* PGI (pgcc, pgfortran)
* Intel (icc, ifort)


Parameters
^^^^^^^^^^

COMPONENTS default to Netlib LAPACK / LapackE, otherwise:

``IntelPar``
  Intel MKL 32-bit integer with Intel OpenMP for ICC, GCC and PGCC
``IntelSeq``
  Intel MKL 32-bit integer without threading for ICC, GCC, and PGCC
``LAPACKE``
  Netlib LapackE for C / C++
``MKL64``
  MKL only: 64-bit integers  (default is 32-bit integers)


Result Variables
^^^^^^^^^^^^^^^^

``LAPACK_FOUND``
  Lapack libraries were found
``LAPACK_<component>_FOUND``
  LAPACK <component> specified was found
``LAPACK_LIBRARIES``
  Lapack library files (including BLAS
``LAPACK_INCLUDE_DIRS``
  Lapack include directories (for C/C++)


References
^^^^^^^^^^

* Pkg-Config and MKL:  https://software.intel.com/en-us/articles/intel-math-kernel-library-intel-mkl-and-pkg-config-tool
* MKL for Windows: https://software.intel.com/en-us/mkl-windows-developer-guide-static-libraries-in-the-lib-intel64-win-directory
* MKL Windows directories: https://software.intel.com/en-us/mkl-windows-developer-guide-high-level-directory-structure
#]=======================================================================]


cmake_policy(VERSION 3.3)

function(mkl_libs)
# https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor

set(_mkl_libs ${ARGV})
if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU AND Fortran IN_LIST project_languages)
  list(INSERT _mkl_libs 0 mkl_gf_${_mkl_bitflag}lp64)
endif()

foreach(s ${_mkl_libs})
  find_library(LAPACK_${s}_LIBRARY
           NAMES ${s}
           PATHS $ENV{MKLROOT}/lib
                 $ENV{MKLROOT}/lib/intel64
                 $ENV{MKLROOT}/lib/intel64_win
                 $ENV{MKLROOT}/../compiler/lib
                 $ENV{MKLROOT}/../compiler/lib/intel64
                 $ENV{MKLROOT}/../compiler/lib/intel64_win
           HINTS ${MKL_LIBRARY_DIRS}
           NO_DEFAULT_PATH)
  if(NOT LAPACK_${s}_LIBRARY)
    message(FATAL_ERROR "MKL component not found: " ${s})
  endif()

  list(APPEND LAPACK_LIB ${LAPACK_${s}_LIBRARY})
endforeach()

if(NOT BUILD_SHARED_LIBS AND (UNIX AND NOT APPLE))
  set(LAPACK_LIB -Wl,--start-group ${LAPACK_LIB} -Wl,--end-group)
endif()

list(APPEND LAPACK_LIB pthread ${CMAKE_DL_LIBS} m)

set(LAPACK_LIBRARY ${LAPACK_LIB} PARENT_SCOPE)
set(LAPACK_INCLUDE_DIR $ENV{MKLROOT}/include ${MKL_INCLUDE_DIRS} PARENT_SCOPE)

endfunction()

#===============================================================================

get_property(project_languages GLOBAL PROPERTY ENABLED_LANGUAGES)

find_package(PkgConfig)

if(BUILD_SHARED_LIBS)
  set(_mkltype dynamic)
else()
  set(_mkltype static)
endif()


set(_mkl_bitflag)
if(MKL64 IN_LIST LAPACK_FIND_COMPONENTS)
  set(_mkl_bitflag i)
endif()


if(IntelPar IN_LIST LAPACK_FIND_COMPONENTS)
  pkg_check_modules(MKL mkl-${_mkltype}-${_mkl_bitflag}lp64-iomp)

  if(WINDOWS)
    set(_mp iomp5md)
  else()
    set(_mp iomp5)
  endif()

  mkl_libs(mkl_intel_${_mkl_bitflag}lp64 mkl_intel_thread mkl_core ${_mp})

  if(LAPACK_LIBRARY)
    set(LAPACK_IntelPar_FOUND true)
    if(MKL64 IN_LIST LAPACK_FIND_COMPONENTS)
      set(LAPACK_MKL64_FOUND true)
    endif()
  endif()
elseif(IntelSeq IN_LIST LAPACK_FIND_COMPONENTS)
  pkg_check_modules(MKL mkl-${_mkltype}-${_mkl_bitflag}lp64-seq)

  mkl_libs(mkl_intel_${_mkl_bitflag}lp64 mkl_sequential mkl_core)

  if(LAPACK_LIBRARY)
    set(LAPACK_IntelSeq_FOUND true)
    if(MKL64 IN_LIST LAPACK_FIND_COMPONENTS)
      set(LAPACK_MKL64_FOUND true)
    endif()
  endif()
else()
  find_package(Threads REQUIRED)

  pkg_check_modules(LAPACK lapack)
  find_library(LAPACK_LIB
    NAMES lapack
    HINTS ${LAPACK_LIBRARY_DIRS})

  if(LAPACKE IN_LIST LAPACK_FIND_COMPONENTS)
    pkg_check_modules(LAPACKE lapacke)
    find_library(LAPACKE_LIBRARY
      NAMES lapacke
      HINTS ${LAPACKE_LIBRARY_DIRS})

    find_path(LAPACK_INCLUDE_DIR
      NAMES lapacke.h
      HINTS ${LAPACKE_INCLUDE_DIRS})

    if(LAPACKE_LIBRARY)
      set(LAPACK_LAPACKE_FOUND true)
      set(LAPACK_LIBRARY ${LAPACKE_LIBRARY})
    else()
      set(LAPACK_LAPACKE_FOUND false)
    endif()

  else()
    unset(LAPACK_LIBRARY)
  endif()

  pkg_check_modules(BLAS blas)
  find_library(BLAS_LIBRARY
    NAMES refblas blas
    HINTS ${BLAS_LIBRARY_DIRS})

  if(NOT BLAS_LIBRARY)
    message(FATAL_ERROR "BLAS not found")
  endif()

  mark_as_advanced(BLAS_LIBRARY)

  list(APPEND LAPACK_LIBRARY ${LAPACK_LIB} ${BLAS_LIBRARY} ${CMAKE_THREAD_LIBS_INIT})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  LAPACK
  REQUIRED_VARS LAPACK_LIBRARY
  HANDLE_COMPONENTS)

if(LAPACK_FOUND)
  set(LAPACK_LIBRARIES ${LAPACK_LIBRARY})
  set(LAPACK_INCLUDE_DIRS ${LAPACK_INCLUDE_DIR})
endif()

mark_as_advanced(LAPACK_LIBRARY LAPACK_INCLUDE_DIR)
