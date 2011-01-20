from distutils.core import setup
#from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Distutils.extension import Extension

sourcefiles = ['eio.pyx']

setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [Extension('eio',
                             sourcefiles,
                             libraries = ['eio'],
                            )]
)
