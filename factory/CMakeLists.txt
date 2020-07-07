# tests CMake's built-in FindBLAS
cmake_minimum_required(VERSION 3.12)
project(Lapack_OEM LANGUAGES C Fortran)

if(CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
  set(BLA_VENDOR Intel10_64lp)
  if(WIN32)
    file(TO_CMAKE_PATH "$ENV{MKLROOT}" MKLROOT)
  else()
    set(MKLROOT "$ENV{MKLROOT}")
  endif()
endif()

find_package(BLAS)
find_package(LAPACK)
