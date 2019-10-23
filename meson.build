project('lapack_demo', 'c',
  default_options : ['default_library=static', 'buildtype=release'],
  meson_version: '>= 0.52.1')

cc = meson.get_compiler('c')

mkl_root = get_option('MKL_ROOT')
usemkl = 0
if cc.get_id() == 'intel' or cc.get_id() == 'intel-cl' or mkl_root != ''
  usemkl = 1
endif

# issue with Meson--CMake alone works OK
# lapack = dependency('lapack', method: 'cmake', cmake_module_path: 'cmake/Modules')
if usemkl == 1
  c_code = '#include "mkl_lapacke.h"'
  lapacke_lib = []
  foreach n: ['mkl_intel_lp64', 'mkl_sequential', 'mkl_core']
    lapacke_lib += cc.find_library(n)
  endforeach
else
  c_code = '#include "lapacke.h"'
  lapacke_lib = cc.find_library('lapacke', required: false, disabler: true)
endif
if not cc.links(c_code+'''
int main(void) { return 0; }''', dependencies: lapacke_lib, name: 'LAPACKE')
  lapacke_lib = disabler()
endif

subdir('c_src')

#=== Fortran (optional)

if not add_languages('fortran', required: false)
  subdir_done()
endif

fc = meson.get_compiler('fortran')

lapack_lib = disabler()
lapack95_lib = disabler()
if usemkl == 1
  lapack_lib = []
  foreach n: ['mkl_blas95_lp64', 'mkl_lapack95_lp64', 'mkl_intel_lp64', 'mkl_sequential', 'mkl_core']
    lapack_lib += fc.find_library(n)
  endforeach
  if not fc.links('print *,disnan(0.); end', dependencies: lapack_lib, name: 'LAPACK')
    lapack_lib = disabler()
    lapack95_lib = disabler()
  else
    lapack95_lib = lapack_lib
  endif
else
  foreach n: ['lapack-netlib', 'lapack']
    lapack_lib = fc.find_library(n, required: false, disabler: true)
    if fc.links('print *,disnan(0.); end', dependencies: lapack_lib, name: 'LAPACK')
      break
    else
      lapack_lib = disabler()
    endif
  endforeach

  lapack95_lib = fc.find_library('lapack95', required: false, disabler: true)
  if lapack95_lib.found()
    lapack_lib = [lapack95_lib, lapack_lib]
  endif

endif

subdir('fortran_src')
