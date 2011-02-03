from distutils.core import setup
#from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Distutils.extension import Extension

setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [Extension('pyeio',
                             ['pyeio.pyx'],
                             libraries = ['eio'],
                             pyrex_gdb = 1,
                            )]
)
