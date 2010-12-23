from eio cimport *

def init(want_poll=None, done_poll=None):
    eio_init(<void*>want_poll, <void*>done_poll)

cdef int res_cb (eio_req *req):
    print 'callback'
    print ("res_cb(%d|%s) = %d\n", req.type, <int>req.data if req.data else "?", EIO_RESULT (req))

    #if req.result < 0:
        #abort()

    return 0
    
def mkdir(path, mode=0777, pri=0):
    print 'making dir'
    eio_mkdir(path, <mode_t>mode, 0, res_cb, "mkdir");
    print 'made dir'

def poll():
    return eio_poll();

#def find(f):
#    find_cheeses(callback, <void*>f)
#    
#cdef void callback(char *name, void *f):
#    (<object>f)(name)
