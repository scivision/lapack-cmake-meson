cmake_minimum_required(VERSION 3.7)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release" FORCE)
endif()
project(lapack_demo C)
enable_testing()

option(atlas "Atlas Lapack implementation")
option(lapack95 "use Lapack95")
option(USEOpenBLAS "OpenBLAS")

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.12)
  cmake_policy(SET CMP0074 NEW)
endif()

# this ensures we use our clean FindLapack, instead of old factory FindLapack
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

# if working Fortran compiler present, enable Fortran before searching for libraries
include(CheckLanguage)
check_language(Fortran)
if(CMAKE_Fortran_COMPILER)
  enable_language(Fortran)
endif()

# Now we're ready to Find Lapack
if(atlas)
  set(USEMKL 0)
  find_package(LAPACK COMPONENTS Atlas REQUIRED)
  set(atlas 1)
elseif(USEMKL OR DEFINED ENV{MKLROOT})
  set(USEMKL 1)
  if(lapack95)
    find_package(LAPACK COMPONENTS MKL LAPACK95 REQUIRED)
  else()
    find_package(LAPACK COMPONENTS MKL REQUIRED)
  endif()
elseif(USEOpenBLAS)
  set(USEMKL 0)
  set(USEOpenBLAS 1)
  find_package(LAPACK COMPONENTS OpenBLAS REQUIRED)
else()
  set(USEMKL 0)
  find_package(LAPACK COMPONENTS Netlib LAPACKE)  # netlib -- apt install liblapacke-dev
endif()

# Last ditch fallback
if(NOT LAPACK_FOUND)
  find_package(LAPACK)
endif()

# here are some exmaple programs using Lapack
if(CMAKE_C_COMPILER AND (LAPACK_MKL_FOUND OR LAPACK_OpenBLAS_FOUND OR LAPACK_Atlas_FOUND OR LAPACK_LAPACKE_FOUND))
  add_subdirectory(c_src)
endif()

if(CMAKE_Fortran_COMPILER AND LAPACK_FOUND)
  add_subdirectory(fortran_src)
endif()

# install (just for demonstrating concept)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  if(WIN32)
    set(HOME $ENV{USERPROFILE})
  else()
    set(HOME $ENV{HOME})
  endif()

  set(CMAKE_INSTALL_PREFIX "${HOME}/lapack_demo" CACHE PATH "..." FORCE)
endif()
