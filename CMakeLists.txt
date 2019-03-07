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
  find_package(LAPACK REQUIRED)  # netlib -- requires LapackE  apt install liblapacke-dev
  set(USEMKL 0)
endif()


add_executable(svd_c example_gesvd.c)
target_include_directories(svd_c PRIVATE ${LAPACK_INCLUDE_DIRS})
target_link_libraries(svd_c PRIVATE ${LAPACK_LIBRARIES} m)
target_compile_definitions(svd_c PRIVATE USEMKL=${USEMKL})

add_test(NAME C-SVD COMMAND svd_c)
set_tests_properties(C-SVD PROPERTIES
  ENVIRONMENT MKL_VERBOSE=1)
