cdef extern from "Python.h":

    ctypedef struct PyTypeObject:
        pass

    ctypedef struct PyObject:
        Py_ssize_t ob_refcnt
        PyTypeObject * ob_type
    
    ###############################################################################################
    # compile
    ###############################################################################################

    ctypedef struct PyCodeObject:
        int       co_argcount
        int       co_nlocals
        int       co_stacksize
        int       co_flags
        PyObject *co_code
        PyObject *co_consts
        PyObject *co_names
        PyObject *co_varnames
        PyObject *co_freevars
        PyObject *co_cellvars
        PyObject *co_filename
        PyObject *co_name
        int       co_firstlineno
        PyObject *co_lnotab

    ###############################################################################################
    # frame
    ###############################################################################################

    ctypedef struct PyFrameObject:
        PyFrameObject *f_back
        PyCodeObject  *f_code
        PyObject *f_builtins
        PyObject *f_globals
        PyObject *f_locals
        PyObject *f_trace
        PyObject *f_exc_type
        PyObject *f_exc_value
        PyObject *f_exc_traceback
        int f_lasti
        int f_lineno
        int f_restricted
        int f_iblock
        int f_nlocals
        int f_ncells
        int f_nfreevars
        int f_stacksize

    ###############################################################################################
    # pyeval
    # Be extremely careful with these functions.
    ###############################################################################################

    ctypedef struct PyThreadState:
        PyFrameObject * frame
        int recursion_depth
        void * curexc_type, * curexc_value, * curexc_traceback
        void * exc_type, * exc_value, * exc_traceback

    int                 Py_IsInitialized                ()
    int                 PyEval_ThreadsInitialized       ()
    void                PyEval_InitThreads              ()
    void                PyEval_AcquireLock              ()
    void                PyEval_ReleaseLock              ()
    void                PyEval_AcquireThread            (PyThreadState *)
    void                PyEval_ReleaseThread            (PyThreadState *)
    PyThreadState*      PyEval_SaveThread               ()
    void                PyEval_RestoreThread            (PyThreadState *)

    ###############################################################################################
    # pystate
    # Be extremely careful with these functions.  Read PEP 311 for more detail.
    ###############################################################################################

    ctypedef int PyGILState_STATE
    PyGILState_STATE    PyGILState_Ensure               ()
    void                PyGILState_Release              (PyGILState_STATE)

    ctypedef struct PyInterpreterState:
        pass

    void                PyThreadState_Clear             (PyThreadState *)
    PyThreadState*      PyThreadState_New               (PyInterpreterState *)
    void                PyThreadState_Clear             (PyThreadState *)
    void                PyThreadState_Delete            (PyThreadState *)
    PyThreadState*      PyThreadState_Get               ()
    PyThreadState*      PyThreadState_Swap              (PyThreadState *tstate)
    # XXX: Borrowed reference.
    #object              PyThreadState_GetDict          ()

from pyeio cimport *


cdef object _py_want_poll_cb
cdef object _py_done_poll_cb

cdef void _want_poll() with gil:
    #cdef PyGILState_STATE gstate
    #gstate = PyGILState_Ensure()
    print 'initialized:', Py_IsInitialized(), 'threads:', PyEval_ThreadsInitialized()
    if Py_IsInitialized() == 0:
        print 'returning!!!!!!!!!!'
        return
    
    #print 'in _done_poll'

    global _py_want_poll_cb
    if _py_want_poll_cb:
        _py_want_poll_cb()
    
    # Release the thread. No Python API allowed beyond this point.
    #PyGILState_Release(gstate)

cdef void _done_poll() with gil:
    #PyEval_InitThreads()
    print 'initialized:', Py_IsInitialized(), 'threads:', PyEval_ThreadsInitialized()
    if Py_IsInitialized() == 0:
        print 'returning!!!!!!!!!!'
        return
    
    #print 'in _done_poll'

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
    print 'FFFFFFFFFFFFFFFFFFFFFFFFFFF'
    #print 'callback', req.data
    #return 0

def nop():
    #PyEval_InitThreads()
    #cdef PyGILState_STATE gstate
    #gstate = PyGILState_Ensure()
    
    print 'in nop'
    eio_nop(0, NULL, NULL)

    ## Release the thread. No Python API allowed beyond this point.
    #PyGILState_Release(gstate)


#    eio_req *eio_mkdir     (char *path, mode_t mode, int pri, eio_cb cb, void *data)
def mkdir(path, mode=0777, pri=0, cb=None, data=None):
    cdef eio_req *r
    with nogil:
        #r = eio_mkdir(path, <mode_t>mode, pri, <eio_cb><void *>cb, <void*>data);
        r = eio_mkdir(path, <mode_t>mode, pri, status_callback, <void*>data);

def rmdir(path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_rmdir(path, 0, status_callback, <void*>callback);
        #eio_rmdir     (char *path, int pri, eio_cb cb, void *data)

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
