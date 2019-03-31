
svd_c = executable('svd_c', 'example_gesvd.c',
  dependencies: lapack,
  c_args: ['-DUSEMKL=' + '@0@'.format(usemkl),
           '-DUSEATLAS=' + '@0@'.format(atlas)]
            )

test('C-SVD', svd_c,
  env: 'MKL_VERBOSE=1')
