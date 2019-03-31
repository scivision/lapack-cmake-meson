project('lapack_demo', 'c', default_options : ['default_library=static'])

cc = meson.get_compiler('c')
ccid = cc.get_id()

usefortran = add_languages('fortran', required: false)

atlas = get_option('atlas')
usemkl = get_option('usemkl')
lapack95 = get_option('lapack95')
# Now we're ready to Find Lapack

if atlas == 1
  lapack = dependency('lapack')
elif usemkl == 1
  if lapack95 == 1
    lapack = dependency('lapack')
  else
    lapack = dependency('lapack')
  endif
else
  lapacke = dependency('lapacke')
  lapack = dependency('lapack')
  lapack = [lapacke, lapack]
  # netlib -- apt install liblapacke-dev
endif
# here are some example program using Lapack
subdir('c_src')

if usefortran
  subdir('fortran_src')
endif
