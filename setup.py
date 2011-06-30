import os
from distutils.core import setup
from Cython.Distutils import build_ext
from Cython.Distutils.extension import Extension

pyeio_extension = Extension('eio', ['eio.pyx'])

def configure_pyeio():
    if os.path.exists('libeio/config.h'):
        print 'libeio/config.h found, skipping libeio configuration'
    else:
        print 'libeio/config.h not found, configuring libeio'
        os.system('cd libeio; autoreconf --install --symlink --force')
        os.system('cd libeio; ./configure')

pyeio_extension.configure = configure_pyeio

class my_build_ext(build_ext):

    def build_extension(self, ext):
        if getattr(ext, 'configure', None):
            ext.configure()
        return build_ext.build_extension(self, ext)

setup(
    cmdclass = {'build_ext': my_build_ext},
    ext_modules = [pyeio_extension]
)
