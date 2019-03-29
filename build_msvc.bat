call c:\"Program Files (x86)"\IntelSWTools\compilers_and_libraries\windows\mkl\bin\mklvars.bat intel64

cd build

del CMakeCache.txt

cmake -G "Visual Studio 15 2017" -A x64 ..

cmake --build .

set MKL_VERBOSE=1

cmake --build . --target RUN_TESTS