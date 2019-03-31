project('lapack_demo', 'c', default_options : ['default_library=static'])

atlas = get_option('atlas')
usemkl = get_option('usemkl')
lapack95 = get_option('lapack95')

cc = meson.get_compiler('c')
ccid = cc.get_id()


if host_machine.system() == 'windows'
  usemkl = 1

  if ccid == 'msvc'
    usefortran = false
  elif ccid != 'gcc'
    # MKL does not currently support MinGW on Windows
    usefortran = add_languages('fortran', required: false)
  endif
else
  usefortran = add_languages('fortran', required: false)
endif


if atlas == 1
  lapack = dependency('lapack', modules: 'atlas')
elif usemkl == 1
  if lapack95 == 1
    lapack = dependency('lapack', modules: 'mkl95')
  else
    lapack = dependency('lapack', modules: 'mkl')
  endif
else # netlib -- apt install liblapacke-dev
  lapacke = dependency('lapacke')
  lapack = dependency('lapack')
  lapack = [lapacke, lapack]
endif
# here are some example program using Lapack
subdir('c_src')

if usefortran
  subdir('fortran_src')
endif
