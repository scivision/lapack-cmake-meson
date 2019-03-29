
svd_c = executable('svd_c', 'example_gesvd.c',
  dependencies: lapack)

test('C-SVD', svd_c,
  env: 'MKL_VERBOSE=1')
