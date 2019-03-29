call c:\"Program Files (x86)"\IntelSWTools\compilers_and_libraries\windows\mkl\bin\mklvars.bat intel64

cd build

del CMakeCache.txt

set FC=pgfortran
set CC=pgcc

cmake -G "MinGW Makefiles" ..

cmake --build .

set MKL_VERBOSE=1


ctest -V