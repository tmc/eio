cdef extern from "Python.h":
    int                 Py_IsInitialized                ()
    int                 PyEval_ThreadsInitialized       ()
    void                PyEval_InitThreads              ()

from eio cimport *


cdef object _py_want_poll_cb
cdef object _py_done_poll_cb

cdef void _want_poll() with gil:
    if Py_IsInitialized() == 0:
        return

    global _py_want_poll_cb
    if _py_want_poll_cb:
        _py_want_poll_cb()
    
cdef void _done_poll() with gil:
    if Py_IsInitialized() == 0:
        return
    global _py_done_poll_cb
    if _py_done_poll_cb:
        _py_done_poll_cb()


def init(want_poll=None, done_poll=None):
    PyEval_InitThreads()
    global _py_done_poll_cb
    global _py_want_poll_cb
    _py_want_poll_cb = want_poll
    _py_done_poll_cb = done_poll
    return eio_init(_want_poll, _done_poll)


cdef int _void_callback(eio_req *req):
    print (<object>req.data)

cdef int status_callback (eio_req *req) with gil:
    print 'status callback', req.data

def nop():
    with nogil:    
        eio_nop(0, NULL, NULL)

#    eio_req *eio_mkdir     (char *path, mode_t mode, int pri, eio_cb cb, void *data)
def mkdir(path, mode=0777, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_mkdir(path, <mode_t>mode, 0, status_callback, <void*>callback)

def rmdir(path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_rmdir(path, 0, status_callback, <void*>callback)

def stat(path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_stat(path, 0, status_callback, <void*>callback)

def lstat(path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_lstat(path, 0, status_callback, <void*>callback)

#eio_req *eio_stat      (char *path, int pri, eio_cb cb, void *data) # stat buffer=ptr2 allocated dynamically

def poll():
    cdef int r
    with nogil:
        r = eio_poll()
    return r

def nreqs():
    return eio_nreqs()

def nready():
    return eio_nready()

def npending():
    return eio_npending()

def nthreads():
    return eio_nthreads()
