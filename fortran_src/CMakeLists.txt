if(NOT CMAKE_Fortran_COMPILER)
  return()
endif()

set(noneed GNU Intel)

if(NOT WIN32 AND NOT CMAKE_Fortran_COMPILER_ID IN_LIST noneed)
  list(APPEND LDFLAGS -lgfortran)
endif()

add_executable(svd_f example_gesvd.f90)
if(atlas OR lapack95)
  target_sources(svd_f PRIVATE atlas_svd.f90)
else()
  target_sources(svd_f PRIVATE lapack_svd.f90)
endif()
target_link_libraries(svd_f PRIVATE ${LAPACK_LIBRARIES} ${LDFLAGS})

add_test(NAME Fortran-SVD COMMAND svd_f)
set_tests_properties(Fortran-SVD PROPERTIES
  ENVIRONMENT MKL_VERBOSE=1)

# just for demonstrating concept
install(TARGETS svd_f
  RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})