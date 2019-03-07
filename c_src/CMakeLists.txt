cmake_minimum_required(VERSION 3.3)
project(LapackE_demo C)
enable_testing()

get_directory_property(hasParent PARENT_DIRECTORY)
if(NOT hasParent)
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules)
endif()

if(NOT USEMKL AND CMAKE_C_COMPILER_ID STREQUAL GNU)  # for old GCC
  list(APPEND LDFLAGS -lgfortran)
endif()

add_executable(svd_c example_gesvd.c)
target_include_directories(svd_c PRIVATE ${LAPACK_INCLUDE_DIRS})
target_link_libraries(svd_c PRIVATE ${LAPACK_LIBRARIES} m ${LDFLAGS})  # FIXME: CMake >= 3.13 target_link_options()
target_compile_definitions(svd_c PRIVATE USEMKL=${USEMKL})

add_test(NAME C-SVD COMMAND svd_c)
set_tests_properties(C-SVD PROPERTIES
  ENVIRONMENT MKL_VERBOSE=1)
