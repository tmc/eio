#### types.h
cdef extern from * nogil:
    ctypedef int pid_t
    ctypedef int dev_t
    ctypedef int ino_t
    ctypedef int mode_t
    ctypedef int nlink_t
    #ctypedef int uid_t
    #ctypedef int gid_t
    ctypedef int dev_t
    ctypedef int off_t
    ctypedef int blksize_t
    ctypedef int blkcnt_t
    ctypedef int fsfilcnt_t
    ctypedef int fsblkcnt_t
    ctypedef int time_t
    ctypedef int mode_t

#### stat.h
cdef extern from "sys/stat.h" nogil:
    struct stat_t "stat":
        dev_t     st_dev     # ID of device containing file
        ino_t     st_ino     # inode number
        mode_t    st_mode    # protection
        int   st_nlink   # number of hard links
        int     st_uid     # user ID of owner
        int     st_gid     # group ID of owner
        dev_t     st_rdev    # device ID (if special file)
        off_t     st_size    # total size, in bytes
        #blksize_t st_blksize # blocksize for filesystem I/O # not on win32
        #blkcnt_t  st_blocks  # number of blocks allocated   # not on win32
        time_t    st_atime   # time of last access
        time_t    st_mtime   # time of last modification
        time_t    st_ctime   # time of last status change

#### statvfs.h (but use eio.c's stuff for win compat)
cdef extern from * nogil:
    struct statvfs_t "statvfs":
      unsigned long  f_bsize    # file system block size
      unsigned long  f_frsize   # fragment size
      fsblkcnt_t     f_blocks   # size of fs in f_frsize units
      fsblkcnt_t     f_bfree    # # free blocks
      fsblkcnt_t     f_bavail   # # free blocks for non-root
      fsfilcnt_t     f_files    # # inodes
      fsfilcnt_t     f_ffree    # # free inodes
      fsfilcnt_t     f_favail   # # free inodes for non-root
      unsigned long  f_fsid     # file system ID
      unsigned long  f_flag     # mount flags
      unsigned long  f_namemax  # maximum filename length

cdef extern from "Python.h":
    int                 Py_IsInitialized                ()
    int                 PyEval_ThreadsInitialized       ()
    void                PyEval_InitThreads              ()
    object PyString_FromStringAndSize(char *s, Py_ssize_t len)
    char * PyString_AsString(object)

cdef extern from "libeio/eio.c":
    enum: EIO_PRI_MIN
    enum: EIO_PRI_MAX
    enum: EIO_PRI_DEFAULT

    enum: EIO_SYNC_FILE_RANGE_WAIT_BEFORE
    enum: EIO_SYNC_FILE_RANGE_WRITE
    enum: EIO_SYNC_FILE_RANGE_WAIT_AFTER

    enum: EIO_CUSTOM
    enum: EIO_OPEN
    enum: EIO_CLOSE
    enum: EIO_DUP2
    enum: EIO_READ
    enum: EIO_WRITE
    enum: EIO_READAHEAD
    enum: EIO_SENDFILE
    enum: EIO_STAT
    enum: EIO_LSTAT
    enum: EIO_FSTAT
    enum: EIO_STATVFS
    enum: EIO_FSTATVFS
    enum: EIO_TRUNCATE
    enum: EIO_FTRUNCATE
    enum: EIO_UTIME
    enum: EIO_FUTIME
    enum: EIO_CHMOD
    enum: EIO_FCHMOD
    enum: EIO_CHOWN
    enum: EIO_FCHOWN
    enum: EIO_SYNC
    enum: EIO_FSYNC
    enum: EIO_FDATASYNC
    enum: EIO_MSYNC
    enum: EIO_MTOUCH
    enum: EIO_SYNC_FILE_RANGE
    enum: EIO_MLOCK
    enum: EIO_MLOCKALL
    enum: EIO_UNLINK
    enum: EIO_RMDIR
    enum: EIO_MKDIR
    enum: EIO_RENAME
    enum: EIO_MKNOD
    enum: EIO_READDIR
    enum: EIO_LINK
    enum: EIO_SYMLINK
    enum: EIO_READLINK
    enum: EIO_GROUP
    enum: EIO_NOP
    enum: EIO_BUSY

    ctypedef int eio_uid_t
    ctypedef int eio_gid_t

    cdef struct eio_dirent
    cdef struct eio_req
    ctypedef double eio_tstamp
    ctypedef int (*eio_cb)(eio_req *req)

    cdef struct eio_req:
      ssize_t result # result of syscall, e.g. result = read (... 
      int type        # EIO_xxx constant ETP
      int int1       # all applicable requests: file descriptor sendfile: output fd open, msync, mlockall, readdir: flags
      long int2      # chown, fchown: uid sendfile: input fd open, chmod, mkdir, mknod: file mode, sync_file_range: flags
      long int3      # chown, fchown: gid
      int errorno    # errno value on syscall return
      char *data
      void *ptr1     # all applicable requests: pathname, old name; readdir: optional eio_dirents
      void *ptr2     # all applicable requests: new name or memory buffer; readdir: name strings

    cdef void * memset (void * ptr, int value, size_t num)
    cdef void * calloc(size_t count, size_t size)

cdef extern from "libeio/eio.c" nogil:

    #ctypedef void (*callback)()
    #int eio_init (void *want_poll, void *done_poll)
    #int eio_init (callback want_poll, callback done_poll)
    int eio_init (void (*want_poll)(), void (*done_poll)())
    int eio_poll ()

    unsigned int eio_nreqs    () # number of requests in-flight
    unsigned int eio_nready   () # number of not-yet handled requests
    unsigned int eio_npending () # number of finished but unhandled requests
    unsigned int eio_nthreads () # number of worker threads in use currently

    void eio_set_min_parallel (unsigned int nthreads)
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
    eio_req *eio_fchown    (int fd, eio_uid_t uid, eio_gid_t gid, int pri, eio_cb cb, void *data)
    eio_req *eio_dup2      (int fd, int fd2, int pri, eio_cb cb, void *data)
    eio_req *eio_sendfile  (int out_fd, int in_fd, off_t in_offset, size_t length, int pri, eio_cb cb, void *data)
    eio_req *eio_open      (char *path, int flags, mode_t mode, int pri, eio_cb cb, void *data)
    eio_req *eio_utime     (char *path, eio_tstamp atime, eio_tstamp mtime, int pri, eio_cb cb, void *data)
    eio_req *eio_truncate  (char *path, off_t offset, int pri, eio_cb cb, void *data)
    eio_req *eio_chown     (char *path, eio_uid_t uid, eio_gid_t gid, int pri, eio_cb cb, void *data)
    eio_req *eio_chmod     (char *path, mode_t mode, int pri, eio_cb cb, void *data)
    eio_req *eio_mkdir     (char *path, mode_t mode, int pri, eio_cb cb, void *data)
    eio_req *eio_readdir   (char *path, int flags, int pri, eio_cb cb, void *data) # result=ptr2 allocated dynamically
    eio_req *eio_rmdir     (char *path, int pri, eio_cb cb, void *data)
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


