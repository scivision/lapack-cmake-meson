
if usemkl == 1 or lapack95_lib.found()
  f_src = files('atlas_svd.f90')
else
  f_src = files('lapack_svd.f90')
endif

svd_f = executable('svd_f', 'example_gesvd.f90', f_src,
  dependencies: lapack_lib)

test('Fortran-SVD', svd_f,
  env: 'MKL_VERBOSE=1', timeout: 10)
