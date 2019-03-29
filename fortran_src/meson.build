

if atlas == 1 or lapack95 == 1
  f_src = files('atlas_svd.f90')
else
  f_src = files('lapack_svd.f90')
endif

svd_f = executable('svd_f', 'example_gesvd.f90', f_src,
  dependencies: lapack)
  
test('Fortran-SVD', svd_f,
  env: 'MKL_VERBOSE=1')
