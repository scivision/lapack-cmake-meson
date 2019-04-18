cmake_minimum_required(VERSION 3.3)
project(lapack_demo C)
enable_testing()

option(BUILD_SHARED_LIBS "static or shared libs")
option(atlas "Atlas Lapack implementation")
option(lapack95 "use Lapack95")
option(USEOpenBLAS "OpenBLAS")

if(NOT CMAKE_BUILD_TYPE)
  # must have FORCE or it won't take effect
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release" FORCE)
endif()

# this ensures we use our clean FindLapack, instead of old factory FindLapack
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

# this forces static libs, as an example. Not necessary in general.
if(NOT BUILD_SHARED_LIBS)
  set(CMAKE_FIND_LIBRARY_SUFFIXES .a .lib)
endif()

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
  find_package(LAPACK COMPONENTS Netlib LAPACKE REQUIRED)  # netlib -- apt install liblapacke-dev
endif()

# here are some exmaple program using Lapack
add_subdirectory(c_src)

add_subdirectory(fortran_src)

# install (just for demonstrating concept)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  if(WIN32)
    set(HOME $ENV{USERPROFILE})
  else()
    set(HOME $ENV{HOME})
  endif()

  set(CMAKE_INSTALL_PREFIX "${HOME}/lapack_demo" CACHE PATH "..." FORCE)
endif()