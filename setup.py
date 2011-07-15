import os
import subprocess
from distutils.core import Extension, setup
from distutils.command.build_ext import build_ext

cython_available = False
try:
    from Cython.Distutils import build_ext
    from Cython.Distutils.extension import Extension
    cython_available = True
except:
    pass

def get_ext_modules():
    if not cython_available:
        eio_extension = Extension('eio', ['eio.c'])
    else:
        eio_extension = Extension('eio', ['eio.pyx'])

    eio_extension.configure = configure_eio
    return [eio_extension]

def configure_eio():
    if os.path.exists('libeio/config.h'):
        print 'libeio/config.h found, skipping libeio configuration'
    else:
        print 'libeio/config.h not found, configuring libeio'
        subprocess.call('sh -c ./autogen.sh', shell=True, cwd='libeio')
        subprocess.call('sh -c ./configure', shell=True, cwd='libeio')


class my_build_ext(build_ext):

    def build_extension(self, ext):
        if getattr(ext, 'configure', None):
            ext.configure()
        return build_ext.build_extension(self, ext)

__version__ = (0, 0, 1, 'a')

setup(
    name = 'eio',
    #packages = ['eio'],
    version = '.'.join([str(x) for x in __version__]),
    cmdclass = {'build_ext': my_build_ext},
    ext_modules = get_ext_modules(),
    author = 'Travis Cline',
    author_email = 'travis.cline@gmail.com',
    url = 'http://github.com/traviscline/eio',
    description = 'gevent compatibility layer for pyzmq',
    long_description=open('README.rst').read(),
    license = 'New BSD',
)
