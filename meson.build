project('lapack_demo', 'c', default_options : ['default_library=static', 'buildtype=release'])

cc = meson.get_compiler('c')
ccid = cc.get_id()

if ccid == 'msvc'
  usefortran = false
else
  usefortran = add_languages('fortran', required: false)
endif

if ccid == 'intel'
  usemkl=1
  atlas=0
  lapack95=1
endif

lapack = dependency('lapack', method: 'cmake', cmake_module_path: 'cmake/Modules')

# here are some example program using Lapack
subdir('c_src')

if usefortran
  subdir('fortran_src')
endif
