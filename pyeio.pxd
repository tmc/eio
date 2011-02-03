cdef extern from "sys/types.h":
    cdef struct dev_t
    cdef struct gid_t
    cdef struct uid_t
    cdef struct off_t

ctypedef int mode_t

cdef extern from "eio.h":

    cdef struct eio_req:
      ssize_t result # result of syscall, e.g. result = read (... 
      int type        # EIO_xxx constant ETP
      char *data

cdef extern from "eio.h":

    cdef struct eio_dirent
    ctypedef int (*eio_cb)(eio_req *req)
    ctypedef double eio_tstamp

    #ctypedef void (*callback)()
    #int eio_init (void *want_poll, void *done_poll)
    #int eio_init (callback want_poll, callback done_poll)
    int eio_init (void (*want_poll)(), void (*done_poll)())
    int eio_poll () nogil

    unsigned int eio_nreqs    () # number of requests in-flight
    unsigned int eio_nready   () # number of not-yet handled requests
    unsigned int eio_npending () # number of finished but unhandled requests
    unsigned int eio_nthreads () # number of worker threads in use currently

    void eio_set_max_poll_reqs (unsigned int nreqs)


    eio_req *eio_nop       (int pri, eio_cb cb, void *data) # does nothing except go through the whole process 
    eio_req *eio_busy      (eio_tstamp delay, int pri, eio_cb cb, void *data) # ties a thread for this long, simulating busyness
    eio_req *eio_sync      (int pri, eio_cb cb, void *data)
    eio_req *eio_fsync     (int fd, int pri, eio_cb cb, void *data)
    eio_req *eio_fdatasync (int fd, int pri, eio_cb cb, void *data)
    eio_req *eio_msync     (void *addr, size_t length, int flags, int pri, eio_cb cb, void *data)
    eio_req *eio_mtouch    (void *addr, size_t length, int flags, int pri, eio_cb cb, void *data)
    eio_req *eio_mlock     (void *addr, size_t length, int pri, eio_cb cb, void *data)
    eio_req *eio_mlockall  (int flags, int pri, eio_cb cb, void *data)
    eio_req *eio_sync_file_range (int fd, off_t offset, size_t nbytes, unsigned int flags, int pri, eio_cb cb, void *data)
    eio_req *eio_close     (int fd, int pri, eio_cb cb, void *data)
    eio_req *eio_readahead (int fd, off_t offset, size_t length, int pri, eio_cb cb, void *data)
    eio_req *eio_read      (int fd, void *buf, size_t length, off_t offset, int pri, eio_cb cb, void *data)
    eio_req *eio_write     (int fd, void *buf, size_t length, off_t offset, int pri, eio_cb cb, void *data)
    eio_req *eio_fstat     (int fd, int pri, eio_cb cb, void *data) # stat buffer=ptr2 allocated dynamically
    eio_req *eio_fstatvfs  (int fd, int pri, eio_cb cb, void *data) # stat buffer=ptr2 allocated dynamically
    eio_req *eio_futime    (int fd, eio_tstamp atime, eio_tstamp mtime, int pri, eio_cb cb, void *data)
    eio_req *eio_ftruncate (int fd, off_t offset, int pri, eio_cb cb, void *data)
    eio_req *eio_fchmod    (int fd, mode_t mode, int pri, eio_cb cb, void *data)
    eio_req *eio_fchown    (int fd, uid_t uid, gid_t gid, int pri, eio_cb cb, void *data)
    eio_req *eio_dup2      (int fd, int fd2, int pri, eio_cb cb, void *data)
    eio_req *eio_sendfile  (int out_fd, int in_fd, off_t in_offset, size_t length, int pri, eio_cb cb, void *data)
    eio_req *eio_open      (char *path, int flags, mode_t mode, int pri, eio_cb cb, void *data)
    eio_req *eio_utime     (char *path, eio_tstamp atime, eio_tstamp mtime, int pri, eio_cb cb, void *data)
    eio_req *eio_truncate  (char *path, off_t offset, int pri, eio_cb cb, void *data)
    eio_req *eio_chown     (char *path, uid_t uid, gid_t gid, int pri, eio_cb cb, void *data)
    eio_req *eio_chmod     (char *path, mode_t mode, int pri, eio_cb cb, void *data)
    eio_req *eio_mkdir     (char *path, mode_t mode, int pri, eio_cb cb, void *data) nogil
    eio_req *eio_readdir   (char *path, int flags, int pri, eio_cb cb, void *data) # result=ptr2 allocated dynamically
    eio_req *eio_rmdir     (char *path, int pri, eio_cb cb, void *data) nogil
    eio_req *eio_unlink    (char *path, int pri, eio_cb cb, void *data)
    eio_req *eio_readlink  (char *path, int pri, eio_cb cb, void *data) # result=ptr2 allocated dynamically
    eio_req *eio_stat      (char *path, int pri, eio_cb cb, void *data) # stat buffer=ptr2 allocated dynamically
    eio_req *eio_lstat     (char *path, int pri, eio_cb cb, void *data) # stat buffer=ptr2 allocated dynamically
    eio_req *eio_statvfs   (char *path, int pri, eio_cb cb, void *data) # stat buffer=ptr2 allocated dynamically
    eio_req *eio_mknod     (char *path, mode_t mode, dev_t dev, int pri, eio_cb cb, void *data)
    eio_req *eio_link      (char *path, char *new_path, int pri, eio_cb cb, void *data)
    eio_req *eio_symlink   (char *path, char *new_path, int pri, eio_cb cb, void *data)
    eio_req *eio_rename    (char *path, char *new_path, int pri, eio_cb cb, void *data)
    eio_req *eio_custom    (eio_cb execute, int pri, eio_cb cb, void *data)


cdef inline ssize_t EIO_RESULT(eio_req *req): # tc was w/o *
    return req.result
