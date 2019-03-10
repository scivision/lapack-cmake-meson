if(NOT CMAKE_Fortran_COMPILER)
  return()
endif()

if(NOT CMAKE_Fortran_COMPILER_ID IN_LIST "GNU;Intel")
  list(APPEND LDFLAGS -lgfortran)
endif()

add_executable(svd_f example_gesvd.f90)
target_include_directories(svd_f PRIVATE ${LAPACK_INCLUDE_DIRS})
target_link_libraries(svd_f PRIVATE ${LAPACK_LIBRARIES} ${LDFLAGS})
target_compile_definitions(svd_f PRIVATE USEMKL=${USEMKL})

add_test(NAME Fortran-SVD COMMAND svd_f)
set_tests_properties(Fortran-SVD PROPERTIES
  ENVIRONMENT MKL_VERBOSE=1)
