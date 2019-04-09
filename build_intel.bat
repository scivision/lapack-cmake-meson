call C:\"Program Files (x86)"\IntelSWTools\compilers_and_libraries\windows\bin\compilervars.bat intel64

cd build

del CMakeCache.txt

set FC=ifort
set CC=icl

cmake -G "MinGW Makefiles" ..

cmake --build .

set MKL_VERBOSE=1

ctest -V