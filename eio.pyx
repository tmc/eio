from eio cimport *
from cpython.buffer cimport *

#### extension types and helper functions

class eio_exception(Exception): pass

cdef eio_req_from_ptr(eio_req* req_ptr):
    r = eio_request()
    r._eio_req = req_ptr
    return r

cdef class eio_request:
    cdef eio_req *_eio_req
    property type:
        def __get__(self):
            return eio_request_types[self._eio_req.type]
    property data:
        def __get__(self):
            return <object><void *>self._eio_req.data
    property result:
        def __get__(self):
            return self._eio_req.result
    property int1:
        def __get__(self):
            return self._eio_req.int1
    property int2:
        def __get__(self):
            return self._eio_req.int2
    property int3:
        def __get__(self):
            return self._eio_req.int3
    property ptr1:
        def __get__(self):
            return <object>self._eio_req.ptr1
    property ptr2:
        def __get__(self):
            return <object>self._eio_req.ptr2

    # custom properties
    property buf:
        def __get__(self):
            return <char *>self._eio_req.ptr2

    def __repr__(self):
        return '<eio_request %s - %s:%s:%s>' % (self.type, self.int1, self.int2, self.int3)

cdef stat_result_from_ptr(stat_t *stat_ptr):
    s = stat_result()
    s._statptr = stat_ptr
    return s

cdef class stat_result:
    cdef stat_t *_statptr
    property st_dev:
        def __get__(self):
            return self._statptr.st_dev
    property st_ino:
        def __get__(self):
            return self._statptr.st_ino
    property st_mode:
        def __get__(self):
            return self._statptr.st_mode
    property st_nlink:
        def __get__(self):
            return self._statptr.st_nlink
    property st_uid:
        def __get__(self):
            return self._statptr.st_uid
    property st_gid:
        def __get__(self):
            return self._statptr.st_gid
    property st_rdev:
        def __get__(self):
            return self._statptr.st_rdev
    property st_size:
        def __get__(self):
            return self._statptr.st_size

    property st_atime:
        def __get__(self):
            return self._statptr.st_atime
    property st_mtime:
        def __get__(self):
            return self._statptr.st_mtime
    property st_ctime:
        def __get__(self):
            return self._statptr.st_ctime

    def __repr__(self):
        fields = ['st_mode', 'st_ino', 'st_dev', 'st_nlink', 'st_uid', 'st_gid', 'st_size', 'st_atime', 'st_mtime', 'st_ctime']
        return 'eio.stat_result(%s)' % ', '.join(['%s=%s' % (f, getattr(self, f, None)) for f in fields])


eio_request_types = [
  'CUSTOM',
  'OPEN', 'CLOSE', 'DUP2',
  'READ', 'WRITE',
  'READAHEAD', 'SENDFILE',
  'STAT', 'LSTAT', 'FSTAT',
  'STATVFS', 'FSTATVFS',
  'TRUNCATE', 'FTRUNCATE',
  'UTIME', 'FUTIME',
  'CHMOD', 'FCHMOD',
  'CHOWN', 'FCHOWN',
  'SYNC', 'FSYNC', 'FDATASYNC',
  'MSYNC', 'MTOUCH', 'SYNC_FILE_RANGE',
  'MLOCK', 'MLOCKALL',
  'UNLINK', 'RMDIR', 'MKDIR', 'RENAME',
  'MKNOD', 'READDIR',
  'LINK', 'SYMLINK', 'READLINK',
  'GROUP', 'NOP',
  'BUSY'
]

#### references to python (want/done)_poll callbacks

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

#### init

def init(want_poll=None, done_poll=None):
    PyEval_InitThreads()
    global _py_done_poll_cb
    global _py_want_poll_cb
    _py_want_poll_cb = want_poll
    _py_done_poll_cb = done_poll
    return eio_init(_want_poll, _done_poll)

#### callbacks

cdef int void_callback(eio_req *req) with gil:
    r = eio_req_from_ptr(req)
    if r.data:
        r.data()
    return 0

cdef int stat_callback (eio_req *req) with gil:
    r = eio_req_from_ptr(req)
    s = stat_result()
    #print 'stat callback', r
    s._statptr = <stat_t *>r.ptr2
    if r.data:
        r.data(s)
    return 0

cdef int result_callback (eio_req *req) with gil:
    r = eio_req_from_ptr(req)
    #print 'result callback', r
    if r.data:
        r.data(r.result)
    return 0

cdef int rw_callback (eio_req *req) with gil:
    r = eio_req_from_ptr(req)
    #print 'rw callback', r, r.result, '"%s"' % r.buf
    if r.data:
        r.data(r)
    return 0

#### misc
def nop():
    with nogil:    
        eio_nop(0, NULL, NULL)

#### posix call wrappers

#eio_open (const char *path, int flags, mode_t mode, int pri, eio_cb cb, void *data)
def open(char *path, int flags, mode_t mode=0777, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_open(path, flags, mode, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_truncate (const char *path, off_t offset, int pri, eio_cb cb, void *data)
def truncate(char *path, off_t offset, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_truncate(path, offset, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_chown (const char *path, uid_t uid, gid_t gid, int pri, eio_cb cb, void *data)
def chown(char *path, eio_uid_t uid, eio_gid_t gid, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_chown(path, uid, gid, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_chmod (const char *path, mode_t mode, int pri, eio_cb cb, void *data)
def chmod(char *path, mode_t mode, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_chmod(path, mode, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_mkdir (const char *path, mode_t mode, int pri, eio_cb cb, void *data)
def mkdir(char *path, mode_t mode=0777, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_mkdir(path, mode, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_rmdir (const char *path, int pri, eio_cb cb, void *data)
def rmdir(char *path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_rmdir(path, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_unlink (const char *path, int pri, eio_cb cb, void *data)
def unlink(char *path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_unlink(path, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_utime (const char *path, eio_tstamp atime, eio_tstamp mtime, int pri, eio_cb cb, void *data)
def utime(char *path, eio_tstamp atime, eio_tstamp mtime, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_utime(path, atime, mtime, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_mknod (const char *path, mode_t mode, dev_t dev, int pri, eio_cb cb, void *data)
def mknod(char *path, mode_t mode=0666, dev_t dev=0, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_mknod(path, mode, dev, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_link (const char *path, const char *new_path, int pri, eio_cb cb, void *data)
def link(char *path, char *new_path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_link(path, new_path, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_symlink (const char *path, const char *new_path, int pri, eio_cb cb, void *data)
def symlink(char *path, char *new_path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_symlink(path, new_path, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_rename (const char *path, const char *new_path, int pri, eio_cb cb, void *data)
def rename(char *path, char *new_path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_rename(path, new_path, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_mlock (void *addr, size_t length, int pri, eio_cb cb, void *data)
def mlock(addr, size_t length, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_mlock(<void *>addr, length, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_close (int fd, int pri, eio_cb cb, void *data)
def close(int fd, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_close(fd, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_sync (int pri, eio_cb cb, void *data)
def sync(callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_sync(EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_fsync (int fd, int pri, eio_cb cb, void *data)
def fsync(int fd, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_fsync(fd, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_fdatasync (int fd, int pri, eio_cb cb, void *data)
def fdatasync(int fd, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_fdatasync(fd, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_futime (int fd, eio_tstamp atime, eio_tstamp mtime, int pri, eio_cb cb, void *data)
def futime(int fd, eio_tstamp atime, eio_tstamp mtime, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_futime(fd, atime, mtime, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_ftruncate (int fd, off_t offset, int pri, eio_cb cb, void *data)
def ftruncate(int fd, off_t offset, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_ftruncate(fd, offset, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_fchmod (int fd, mode_t mode, int pri, eio_cb cb, void *data)
def fchmod(int fd, mode_t mode, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_fchmod(fd, mode, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_fchown (int fd, uid_t uid, gid_t gid, int pri, eio_cb cb, void *data)
def fchown(int fd, eio_uid_t uid, eio_gid_t gid, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_fchown(fd, uid, gid, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_dup2 (int fd, int fd2, int pri, eio_cb cb, void *data)
def dup2(int fd, int fd2, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_dup2(fd, fd2, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)


#eio_read (int fd, void *buf, size_t length, off_t offset, int pri, eio_cb cb, void *data)
def read(int fd, size_t length, off_t offset, callback=None):
    cdef eio_req *r
    cdef char *buffer_ptr
    buffer = PyString_FromStringAndSize(NULL, length);
    buffer_ptr = PyString_AsString(buffer)

    with nogil:
        r = eio_read(fd, buffer_ptr, length, offset, EIO_PRI_DEFAULT, rw_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_write (int fd, void *buf, size_t length, off_t offset, int pri, eio_cb cb, void *data)
def write(int fd, buf, off_t offset=0, callback=None):
    cdef Py_buffer pbuf
    if PyObject_GetBuffer(buf, &pbuf, PyBUF_SIMPLE) == -1:
        raise Exception('Error creating buffer from %s' % buf)
    with nogil:
        r = eio_write(fd, pbuf.buf, <size_t>pbuf.len, offset, EIO_PRI_DEFAULT, rw_callback, <void *>callback)
    return eio_req_from_ptr(r)


#eio_mlockall (int flags, int pri, eio_cb cb, void *data)
#    Like mlockall, but the flag value constants are called EIO_MCL_CURRENT and EIO_MCL_FUTURE.

#eio_msync (void *addr, size_t length, int flags, int pri, eio_cb cb, void *data)
#    Just like msync, except that the flag values are called EIO_MS_ASYNC, EIO_MS_INVALIDATE and EIO_MS_SYNC.

#eio_readlink (const char *path, int pri, eio_cb cb, void *data)
#    If successful, the path read by readlink(2) can be accessed via req->ptr2 and is NOT null-terminated, with the length specified as req->result.

#eio_realpath (const char *path, int pri, eio_cb cb, void *data)
#    Similar to the realpath libc function, but unlike that one, result is -1 on failure and the length of the returned path in ptr2 (which is not 0-terminated) - this is similar to readlink.


#eio_stat (const char *path, int pri, eio_cb cb, void *data)
def stat(char *path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_stat(path, EIO_PRI_DEFAULT, stat_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_lstat (const char *path, int pri, eio_cb cb, void *data)
def lstat(char *path, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_lstat(path, EIO_PRI_DEFAULT, stat_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_fstat (int fd, int pri, eio_cb cb, void *data)
def fstat(int fd, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_fstat(fd, EIO_PRI_DEFAULT, stat_callback, <void *>callback)
    return eio_req_from_ptr(r)

#eio_statvfs (const char *path, int pri, eio_cb cb, void *data)
#eio_fstatvfs (int fd, int pri, eio_cb cb, void *data)
#    Stats a filesystem - if req->result indicates success, then you can access the struct statvfs-like structure via req->ptr2:
#      EIO_STRUCT_STATVFS *statdata = (EIO_STRUCT_STATVFS *)req->ptr2;


#eio_sendfile (int out_fd, int in_fd, off_t in_offset, size_t length, int pri, eio_cb cb, void *data)
def sendfile(int out_fd, int in_fd, off_t in_offset, size_t length, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_sendfile(out_fd, in_fd, in_offset, length, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)
#    Wraps the sendfile syscall. The arguments follow the Linux version, but libeio supports and will use similar calls on FreeBSD, HP/UX, Solaris and Darwin.
#    If the OS doesn't support some sendfile-like call, or the call fails, indicating support for the given file descriptor type (for example, Linux's sendfile might not support file to file copies), then libeio will emulate the call in userspace, so there are almost no limitations on its use.

#eio_readahead (int fd, off_t offset, size_t length, int pri, eio_cb cb, void *data)
def readahead(int fd, off_t offset, size_t length, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_readahead(fd, offset, length, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)
#    Calls readahead(2). If the syscall is missing, then the call is emulated by simply reading the data (currently in 64kiB chunks).

#eio_sync_file_range (int fd, off_t offset, size_t nbytes, unsigned int flags, int pri, eio_cb cb, void *data)
def sync_file_range(int fd, off_t offset, size_t nbytes, unsigned int flags, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_sync_file_range(fd, offset, nbytes, flags, EIO_PRI_DEFAULT, result_callback, <void *>callback)
    return eio_req_from_ptr(r)
#    Calls sync_file_range. If the syscall is missing, then this is the same as calling fdatasync.
#    Flags can be any combination of EIO_SYNC_FILE_RANGE_WAIT_BEFORE, EIO_SYNC_FILE_RANGE_WRITE and EIO_SYNC_FILE_RANGE_WAIT_AFTER.

#eio_busy (eio_tstamp delay, int pri, eio_cb cb, void *data)
def busy(eio_tstamp delay, callback=None):
    cdef eio_req *r
    with nogil:
        r = eio_busy(delay, EIO_PRI_DEFAULT, void_callback, <void *>callback)
    return eio_req_from_ptr(r)


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

def set_min_parallel(unsigned int nthreads):
    eio_set_min_parallel(nthreads)
