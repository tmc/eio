from eio cimport *


#cdef class EioRequest:
#    cdef eio_req *req_data
#    
#    def __init__(self):
#        #print 'EioRequest init'
#        pass
#        
#    cdef set_data(self, eio_req* data):
#        pass
#        #print data.type


cdef int _void_callback(eio_req *req):
    print (<object>req.data)



cdef object _py_want_poll_cb
cdef object _py_done_poll_cb

cdef void _want_poll() with gil:
    global _py_want_poll_cb
    if _py_want_poll_cb:
        _py_want_poll_cb()

cdef void _done_poll() with gil:
    global _py_done_poll_cb
    if _py_done_poll_cb:
        _py_done_poll_cb()

def init(want_poll=None, done_poll=None):
    global _py_done_poll_cb
    global _py_want_poll_cb
    _py_want_poll_cb = want_poll
    _py_done_poll_cb = done_poll
    return eio_init(_want_poll, _done_poll)


cdef int status_callback (eio_req *req):
    print 'callback', req.data
    return 0

def nop():
    eio_nop(0, NULL, NULL)


#    eio_req *eio_mkdir     (char *path, mode_t mode, int pri, eio_cb cb, void *data)
def mkdir(path, mode=0777, pri=0, cb=None, data=None):
    cdef eio_req *r
    #r = eio_mkdir(path, <mode_t>mode, pri, <eio_cb><void *>cb, <void*>data);
    r = eio_mkdir(path, <mode_t>mode, pri, status_callback, <void*>data);

def rmdir(path, callback=None):
    cdef eio_req *r
    r = eio_rmdir(path, 0, status_callback, <void*>callback);
    #eio_rmdir     (char *path, int pri, eio_cb cb, void *data)

def poll():
    return eio_poll();

def nreqs():
    return eio_nreqs()

def nready():
    return eio_nready()

def npending():
    return eio_npending()

def nthreads():
    return eio_nthreads()
