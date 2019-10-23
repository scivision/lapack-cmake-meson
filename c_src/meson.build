
svd_c = executable('svd_c', 'example_gesvd.c',
  dependencies: lapacke_lib,
  c_args: ['-DUSEMKL=' + '@0@'.format(usemkl)])

test('C-SVD', svd_c,
  env: 'MKL_VERBOSE=1', timeout: 10)
