from eio cimport *

#eio_req *eio_nop       (int pri, eio_cb cb, void *data); /* does nothing except go through the whole process */
#ctypedef void eio_cb

cdef class EioRequest:
    cdef eio_req *req_data
    
    def __init__(self):
        print 'EioRequest init'
        
    cdef set_data(self, eio_req* data):
        print 'EioRequest set data'
        #print data.type


def nop(pri, cb=None, data=None):
    cdef eio_req *r
    cdef EioRequest mreq
    #r = eio_nop(pri, <eio_cb><void *>cb, <void *>data)
    r = eio_nop(pri, status_callback, <void *>data)
    
    #mreq.set_data(r)
    return mreq

cdef void _want_poll():
    print '_want poll!!!!!!!!!!!'

cdef void _want_poll():
    print 'done poll!!!!!!!'

def init(want_poll=None, done_poll=None):
    #return eio_init(<void*>want_poll, <void*>done_poll)
    return eio_init(_want_poll, _done_poll)

cdef int status_callback (eio_req *req):
    print 'callback', req.data
    print 'foosdfsdf'
    #print ("res_cb(%d|%s) = %d\n", req.type, req.data if req.data else "?", EIO_RESULT (req))
    #print ("res_cb(%d|%s) = %d\n", req.type, <char *>req.data if req.data else "?", EIO_RESULT (req))

    #if req.result < 0:
        #abort()

    return 0
#aio_mkdir $pathname, $mode, $callback->($status)
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
