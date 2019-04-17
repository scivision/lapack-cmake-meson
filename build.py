#!/usr/bin/env python
"""

## PGI

We assume you're running from the PGI console on Windows, or otherwise have PATH set
to PGI compilers in environment before running this script.


## Intel

We assume you've already:

* Windows: compilervars.bat intel64
* Linux / Mac: source compilervars.sh intel64

or otherwise set environment variable MKLROOT.
This is how Numpy finds Intel MKL / compilers as well.

## MKL

MSVC requires MKL too

"""
from pathlib import Path
import os
import shutil
import subprocess
from typing import Dict, List, Tuple
from argparse import ArgumentParser

MSVC = 'Visual Studio 15 2017'


# %% function
def do_build(build: Path, src: Path,
             compilers: Dict[str, str],
             args: List[str],
             wipe: bool = True,
             dotest: bool = True,
             install: str = None):
    """
    attempts build with Meson or CMake
    TODO: Meson needs better Lapack finding
    """
#    try:
#        meson_setup(build, src, compilers, args, wipe, dotest, install)
#    except (ImportError, FileNotFoundError, RuntimeError):
#        cmake_setup(build, src, compilers, args, wipe, dotest, install)

    cmake_setup(build, src, compilers, args, wipe, dotest, install)


def _needs_wipe(fn: Path, wipe: bool) -> bool:
    if not fn.is_file():
        return False

    with fn.open() as f:
        for line in f:
            if line.startswith('CMAKE_C_COMPILER:FILEPATH'):
                cc = line.split('/')[-1]
                if cc != compilers['CC']:
                    wipe = True
                    break
            elif line.startswith('CMAKE_GENERATOR:INTERNAL'):
                gen = line.split('=')[-1]
                if gen.startswith('Unix') and os.name == 'nt':
                    wipe = True
                    break
                elif gen.startswith(('MinGW', 'Visual')) and os.name != 'nt':
                    wipe = True
                    break
                elif gen.startswith('Visual') and compilers['CC'] != 'cl':
                    wipe = True
                    break

    return wipe


def cmake_setup(build: Path, src: Path, compilers: Dict[str, str],
                args: List[str],
                wipe: bool = True, dotest: bool = True,
                install: str = None):
    """
    attempt to build using CMake >= 3
    """
    cmake_exe = shutil.which('cmake')
    if not cmake_exe:
        raise FileNotFoundError('CMake not available')

    if compilers['CC'] == 'cl':
        wopts = ['-G', MSVC, '-A', 'x64']
    elif os.name == 'nt':
        wopts = ['-G', 'MinGW Makefiles', '-DCMAKE_SH="CMAKE_SH-NOTFOUND']
    else:
        wopts = []

    wopts += args

    if isinstance(install, str) and install.strip():  # path specified
        wopts.append('-DCMAKE_INSTALL_PREFIX:PATH='+str(Path(install).expanduser()))

    cachefile = build / 'CMakeCache.txt'

    wipe = _needs_wipe(cachefile, wipe)

    if wipe and cachefile.is_file():
        cachefile.unlink()

    subprocess.check_call([cmake_exe] + wopts + [str(src)],
                          cwd=build, env=os.environ.update(compilers))

    ret = subprocess.run([cmake_exe, '--build', str(build)],
                         stderr=subprocess.PIPE,
                         universal_newlines=True)

    test_result(ret)
    if ret.returncode:
        return
# %% test
    if dotest:
        ctest_exe = shutil.which('ctest')
        if not ctest_exe:
            raise FileNotFoundError('CTest not available')

        if compilers['CC'] == 'cl':
            subprocess.check_call([cmake_exe, '--build', str(build), '--target', 'RUN_TESTS'])
        else:
            subprocess.check_call([ctest_exe, '--output-on-failure'], cwd=build)
# %% install
    if install is not None:  # blank '' or ' ' etc. will use dfault install path
        subprocess.check_call([cmake_exe, '--build', str(build), '--target', 'install'])


def meson_setup(build: Path, src: Path, compilers: Dict[str, str],
                args: List[str],
                wipe: bool = True, dotest: bool = True,
                install: str = None):
    """
    attempt to build with Meson + Ninja
    """

    meson_exe = [shutil.which('meson')]

    ninja_exe = shutil.which('ninja')

    if not meson_exe or not ninja_exe:
        raise FileNotFoundError('Meson or Ninja not available')

    build_ninja = build / 'build.ninja'

    meson_setup = meson_exe + ['setup'] + args

    if isinstance(install, str) and install.strip():  # path specified
        meson_setup.append('--prefix '+str(Path(install).expanduser()))

    if wipe and build_ninja.is_file():
        meson_setup.append('--wipe')
    meson_setup += [str(build), str(src)]

    if wipe or not build_ninja.is_file():
        subprocess.check_call(meson_setup, env=os.environ.update(compilers))

    ret = subprocess.run([ninja_exe, '-C', str(build)], stderr=subprocess.PIPE,
                         universal_newlines=True)

    test_result(ret)

    if dotest:
        if not ret.returncode:
            subprocess.check_call([meson_exe, 'test', '-C', str(build)])  # type: ignore     # MyPy bug

    if install:
        if not ret.returncode:
            subprocess.check_call([meson_exe, 'install', '-C', str(build)])  # type: ignore     # MyPy bug


def test_result(ret: subprocess.CompletedProcess):
    if not ret.returncode:
        print('\nBuild Complete!')
    else:
        raise RuntimeError(ret.stderr)


# %% compilers
def clang_params(impl: str) -> Tuple[Dict[str, str], List[str]]:
    compilers = {'CC': 'clang', 'CXX': 'clang++', 'FC': 'flang'}

    args = ['-Datlas=1'] if impl == 'atlas' else []

    return compilers, args


def gnu_params(impl: str) -> Tuple[Dict[str, str], List[str]]:
    compilers = {'FC': 'gfortran', 'CC': 'gcc', 'CXX': 'g++'}

    args = ['-Datlas=1'] if impl == 'atlas' else []

    return compilers, args


def intel_params() -> Tuple[Dict[str, str], List[str]]:
    if not os.environ.get('MKLROOT'):
        raise EnvironmentError('must have set MKLROOT by running compilervars.bat or source compilervars.sh before this script.')

    # %% compiler variables
    compilers = {'FC': 'ifort'}
    if os.name == 'nt':
        compilers['CC'] = compilers['CXX'] = 'icl'
    else:
        compilers['CC'] = 'icc'
        compilers['CXX'] = 'icpc'

    args: List[str] = []

    return compilers, args


def msvc_params() -> Tuple[Dict[str, str], List[str]]:
    if not shutil.which('cl'):
        raise EnvironmentError('Must have PATH set to include MSVC cl.exe compiler bin directory')

    compilers = {'CC': 'cl', 'CXX': 'cl'}

    args: List[str] = []

    return compilers, args


def pgi_params(impl: str) -> Tuple[Dict[str, str], List[str]]:
    if not shutil.which('pgcc') or not shutil.which('pgfortran'):
        raise EnvironmentError('Must have PATH set to include PGI compiler bin directory')

    # %% compiler variables
    compilers = {'FC': 'pgfortran', 'CC': 'pgcc'}
    if os.name != 'nt':
        # pgc++ is not on Windows at this time
        compilers['CXX'] = 'pgc++'

    args = ['-Datlas=1'] if impl == 'atlas' else []

    return compilers, args


if __name__ == '__main__':
    p = ArgumentParser()
    p.add_argument('vendor', help='compiler vendor [clang, gnu, intel, msvc, pgi]')
    p.add_argument('-wipe', help='wipe and rebuild from scratch', action='store_true')
    p.add_argument('-i', '--implementation',
                   help='which LAPACK implementation')
    p.add_argument('-n', '--no-test', help='do not run self-test / example', action='store_false')
    p.add_argument('-install', help='specify directory to install to')
    a = p.parse_args()
    # Must have .resolve() to work in general regardless of invocation directory
    src = Path(__file__).parent.resolve()
    build = src / 'build'

    dotest = a.no_test

    if a.vendor == 'clang':
        compilers, args = clang_params(a.implementation)
    elif a.vendor in ('gnu', 'gcc'):
        compilers, args = gnu_params(a.implementation)
    elif a.vendor == 'intel':
        compilers, args = intel_params()
    elif a.vendor == 'msvc':
        compilers, args = msvc_params()
    elif a.vendor == 'pgi':
        compilers, args = pgi_params(a.implementation)
    else:
        raise ValueError('unknown compiler vendor {}'.format(a.vendor))

    do_build(build, src, compilers, args, a.wipe, dotest, a.install)
