cmake_minimum_required(VERSION 3.3)
project(lapack_demo C)
enable_testing()

option(BUILD_SHARED_LIBS "static or shared libs")

if(CMAKE_BUILD_TYPE STREQUAL Debug)
  add_compile_options(-g -O0)
else()
  add_compile_options(-O3)
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

# this forces static libs, as an example. Not necessary in general.
if(NOT BUILD_SHARED_LIBS)
  set(CMAKE_FIND_LIBRARY_SUFFIXES .a .lib)
endif()

if(DEFINED ENV{MKLROOT})
  find_package(LAPACK COMPONENTS IntelPar REQUIRED)
  set(USEMKL 1)
else()
  find_package(LAPACK COMPONENTS LAPACKE REQUIRED)  # netlib -- apt install liblapacke-dev
  set(USEMKL 0)
endif()


add_subdirectory(c_src)
add_subdirectory(fortran_src)
