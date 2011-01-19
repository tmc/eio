from eio cimport *

def init(want_poll=None, done_poll=None):
    return eio_init(<void*>want_poll, <void*>done_poll)

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

def mkdir(path, mode=0777, callback=None):
    cdef eio_req *r
    r = eio_mkdir(path, <mode_t>mode, 0, status_callback, <void*>callback);

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
