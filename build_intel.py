#!/usr/bin/env python
"""
We assume you've already:

* Windows: compilervars.bat intel64
* Linux / Mac: source compilervars.sh intel64

or otherwise set environment variable MKLROOT.
This is how Numpy finds Intel MKL / compilers as well.
"""
from pathlib import Path
import os
import shutil
import subprocess
from typing import Dict
from argparse import ArgumentParser


# %% function
def do_build(build: Path, src: Path, compilers: Dict[str, str],
             wipe: bool = True):
    """
    attempts build with Meson or CMake
    TODO: Meson needs better Lapack finding
    """
    # try:
    #     meson_setup(build, src, compilers)
    # except (FileNotFoundError, RuntimeError):
    #    cmake_setup(build, src, compilers)

    cmake_setup(build, src, compilers, wipe)


def cmake_setup(build: Path, src: Path, compilers: Dict[str, str],
                wipe: bool = True):
    """
    attempt to build using CMake >= 3
    """
    cmake_exe = shutil.which('cmake')
    if not cmake_exe:
        raise FileNotFoundError('CMake not available')

    wopts = ['-G', 'MinGW Makefiles', '-DCMAKE_SH="CMAKE_SH-NOTFOUND'] if os.name == 'nt' else []

    cachefile = build / 'CMakeCache.txt'

    if wipe and cachefile.is_file():
        cachefile.unlink()

    subprocess.check_call([cmake_exe] + wopts + [str(src)],
                          cwd=build, env=os.environ.update(compilers))

    ret = subprocess.run([cmake_exe, '--build', str(build)],
                         stderr=subprocess.PIPE,
                         universal_newlines=True)

    test_result(ret)
    # %% test
    ctest_exe = shutil.which('ctest')
    if not ctest_exe:
        raise FileNotFoundError('CTest not available')

    if not ret.returncode:
        subprocess.check_call([ctest_exe, '--output-on-failure'], cwd=build)


def meson_setup(build: Path, src: Path, compilers: Dict[str, str],
                wipe: bool = True):
    """
    attempt to build with Meson + Ninja
    """
    meson_exe = shutil.which('meson')
    ninja_exe = shutil.which('ninja')

    if not meson_exe or not ninja_exe:
        raise FileNotFoundError('Meson or Ninja not available')

    build_ninja = build / 'build.ninja'

    meson_setup = [meson_exe, 'setup']
    if wipe and build_ninja.is_file():
        meson_setup.append('--wipe')
    meson_setup += [str(build), str(src)]

    if wipe or not build_ninja.is_file():
        subprocess.check_call(meson_setup, env=compilers)

    ret = subprocess.run([ninja_exe, '-C', str(build)], stderr=subprocess.PIPE,
                         universal_newlines=True)

    test_result(ret)

    if not ret.returncode:
        subprocess.check_call([meson_exe, 'test', '-C', str(build)])


def test_result(ret: subprocess.CompletedProcess):
    if not ret.returncode:
        print('\nBuild Complete!')
    else:
        raise RuntimeError(ret.stderr)


if __name__ == '__main__':
    p = ArgumentParser()
    p.add_argument('-wipe', help='wipe and rebuild from scratch', action='store_true')
    a = p.parse_args()
    # Must have .resolve() to work in general regardless of invocation directory
    src = Path(__file__).parent.resolve()
    build = src / 'build'

    if not os.environ.get('MKLROOT'):
        raise EnvironmentError('must have set MKLROOT by running compilervar.bat or source compilervars.sh before this script.')

    # %% compiler variables
    compilers = {'fc': 'ifort'}
    if os.name == 'nt':
        compilers['cc'] = compilers['cxx'] = 'icl'
    else:
        compilers['cc'] = 'icc'
        compilers['cxx'] = 'icpc'

    do_build(build, src, compilers, a.wipe)
