cmake_minimum_required(VERSION 3.3)
project(LapackE_demo Fortran)
enable_testing()

get_directory_property(hasParent PARENT_DIRECTORY)
if(NOT hasParent)
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules)
endif()


add_executable(svd_f example_gesvd.f90)
target_include_directories(svd_f PRIVATE ${LAPACK_INCLUDE_DIRS})
target_link_libraries(svd_f PRIVATE ${LAPACK_LIBRARIES})
target_compile_definitions(svd_f PRIVATE USEMKL=${USEMKL})

add_test(NAME Fortran-SVD COMMAND svd_f)
set_tests_properties(Fortran-SVD PROPERTIES
  ENVIRONMENT MKL_VERBOSE=1)
