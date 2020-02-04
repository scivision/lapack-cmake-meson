set(need_gf GNU Clang)

if(NOT USEMKL AND CMAKE_C_COMPILER_ID IN_LIST need_gf)
  list(APPEND LDFLAGS -lgfortran)
endif()

if(NOT WIN32)
  list(APPEND LDFLAGS m)
endif()

add_executable(svd_c example_gesvd.c)
target_include_directories(svd_c PRIVATE ${LAPACK_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(svd_c PRIVATE ${LAPACK_LIBRARIES} ${LDFLAGS})
target_compile_definitions(svd_c PRIVATE USEMKL=${USEMKL} USEATLAS=${atlas} USEOpenBLAS=${USEOpenBLAS})

add_test(NAME C-SVD COMMAND svd_c)
set_tests_properties(C-SVD PROPERTIES
  ENVIRONMENT MKL_VERBOSE=1)
