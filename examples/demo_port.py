"""
porting of libeio's demo.c
"""

def print_stats():
    print 'stats'
    print 'num reqs:\t', eio.nreqs()
    print 'num ready:\t', eio.nready()
    print 'num pending:\t', eio.npending()
    print 'num threads:\t', eio.nthreads()


import os
import sys
import stat
import time
import select

##include <stdio.h>
##include <stdlib.h>
##include <unistd.h>
##include <poll.h>
##include <string.h>
##include <assert.h>
##include <fcntl.h>
##include <sys/types.h>
##include <sys/stat.h>
#
##include "eio.h"
import eio
#
#int respipe [2];
respipe = []
#
#void
#want_poll (void)
def want_poll():
#{
#  char dummy;
#  printf ("want_poll ()\n");
    #print 'want_poll ()'
    os.write(respipe[1], ' ')
    #print 'done want_poll ()'
#  write (respipe [1], &dummy, 1);
#}
#
#void
#done_poll (void)
def done_poll():
#{
#  char dummy;
#  printf ("done_poll ()\n");
    #print 'done_poll ()'
    os.read(respipe[0], 1)
    #print 'done done_poll ()'
#  read (respipe [0], &dummy, 1);
#}
#
#void
#event_loop (void)
def event_loop():
#{
#  // an event loop. yeah.
#  struct pollfd pfd;
#  pfd.fd     = respipe [0];
#  pfd.events = POLLIN;
#
    try:
        p = select.poll()
        p.register(respipe[0], select.POLLIN)
#  printf ("\nentering event loop\n");
    #print 'entering event loop'
#  while (eio_nreqs ())
        while eio.nreqs():
#    {
#      poll (&pfd, 1, -1);
            sys.stdout.write('.')
            sys.stdout.flush()
            p.poll(1000)
#      printf ("eio_poll () = %d\n", eio_poll ());
        #print 'eio_poll () = %d' % eio.poll()
            eio.poll()
    except AttributeError:
        # no poll, stupidily wait 500ms
        time.sleep(0.5)
        while eio.nreqs():
            sys.stdout.write('.')
            sys.stdout.flush()
            eio.poll()

#    }
#  printf ("leaving event loop\n");
    #print 'leaving event loop'
#}
#
#int
#res_cb (eio_req *req)
def res_cb(req):
#{
#  printf ("res_cb(%d|%s) = %d\n", req->type, req->data ? req->data : "?", EIO_RESULT (req));
    print 'res_cb(%d|%s) = %d' % (req.type, req.data or '?', req.result)
#
#  if (req->result < 0)
#    abort ();
    if req.result < 0:
        print 'XXX', 'bad result, aborting'
        os.abort()
#
#  return 0;
    return 0
#}
#
#int
#readdir_cb (eio_req *req)
#{
#  char *buf = (char *)EIO_BUF (req);
#
#  printf ("readdir_cb = %d\n", EIO_RESULT (req));
#
#  if (EIO_RESULT (req) < 0)
#    return 0;
#
#  while (EIO_RESULT (req)--)
#    {
#      printf ("readdir = <%s>\n", buf);
#      buf += strlen (buf) + 1;
#    }
#
#  return 0;
#}
#
#int
#stat_cb (eio_req *req)
#{
#  struct stat *buf = EIO_STAT_BUF (req);
#
#  if (req->type == EIO_FSTAT)
#    printf ("fstat_cb = %d\n", EIO_RESULT (req));
#  else
#    printf ("stat_cb(%s) = %d\n", EIO_PATH (req), EIO_RESULT (req));
#
#  if (!EIO_RESULT (req))
#    printf ("stat size %d perm 0%o\n", buf->st_size, buf->st_mode & 0777);
#
#  return 0;
#}
def stat_callback(stat_info):
    print 'py stat_cb', stat_info
    
#
#int
#read_cb (eio_req *req)
#{
#  unsigned char *buf = (unsigned char *)EIO_BUF (req);
#
#  printf ("read_cb = %d (%02x%02x%02x%02x %02x%02x%02x%02x)\n",
#          EIO_RESULT (req),
#          buf [0], buf [1], buf [2], buf [3],
#          buf [4], buf [5], buf [6], buf [7]);
#
#  return 0;
#}
#
#int last_fd;
last_fd = None
#
#int
#open_cb (eio_req *req)
def open_callback(fd):
    global last_fd
    last_fd = fd
    print 'open_callback, fd:', fd

#{
#  printf ("open_cb = %d\n", EIO_RESULT (req));
#
#  last_fd = EIO_RESULT (req);
#
#  return 0;
#}
#

def read_callback(r):
    print 'READ CALLBACK', r, len(r.buf), r.buf


#int
#main (void)
if __name__ == '__main__':
#{
#  printf ("pipe ()\n");
    print 'pipe ()'
#  if (pipe (respipe)) abort ();
    respipe = os.pipe()
#
#  printf ("eio_init ()\n");
    print 'eio_init ()'

#  if (eio_init (want_poll, done_poll)) abort ();
    if eio.init(want_poll, done_poll):
#    if eio.init():
        print 'init failed, aborting'
        os.abort()
#
#  do
#    {
#      /* avoid relative paths yourself(!) */
#      eio_mkdir ("eio-test-dir", 0777, 0, res_cb, "mkdir");
    r = eio.mkdir('eio-test-dir', 0777)
#      eio_nop (0, res_cb, "nop");
    eio.nop()
#      eio_stat ("eio-test-dir", 0, stat_cb, "stat");
    eio.stat('eio-test-dir', stat_callback)
#      eio_lstat ("eio-test-dir", 0, stat_cb, "stat");
    eio.lstat('eio-test-dir')
#      eio_open ("eio-test-dir/eio-test-file", O_RDWR | O_CREAT, 0777, 0, open_cb, "open");
    eio.open('eio-test-dir/eio-test-file', os.O_RDWR | os.O_CREAT, 0777, open_callback)
#      eio_symlink ("test", "eio-test-dir/eio-symlink", 0, res_cb, "symlink");
    eio.symlink('test', 'eio-test-dir/eio-symlink')
#      eio_mknod ("eio-test-dir/eio-fifo", S_IFIFO, 0, 0, res_cb, "mknod");
    eio.mknod('eio-test-dir/eio-fifo', stat.S_IFIFO, 0)
#      event_loop ();
    event_loop()
#
#      eio_utime ("eio-test-dir", 12345.678, 23456.789, 0, res_cb, "utime");
    eio.utime('eio-test-dir', 12345.678, 23456.789)
#      eio_futime (last_fd, 92345.678, 93456.789, 0, res_cb, "futime");
    eio.futime(last_fd, 92345.678, 93456.789)
#      eio_chown ("eio-test-dir", getuid (), getgid (), 0, res_cb, "chown");
    if hasattr(os, 'getuid'):
        eio.chown('eio-test-dir', os.getuid(), os.getgid())
#      eio_fchown (last_fd, getuid (), getgid (), 0, res_cb, "fchown");
        eio.fchown(last_fd, os.getuid(), os.getgid())
#      eio_fchmod (last_fd, 0723, 0, res_cb, "fchmod");
        eio.fchmod(last_fd, 0723, 0)
#      eio_readdir ("eio-test-dir", 0, 0, readdir_cb, "readdir");
#      eio_readdir ("/nonexistant", 0, 0, readdir_cb, "readdir");
#      eio_fstat (last_fd, 0, stat_cb, "stat");
#      eio_write (last_fd, "test\nfail\n", 10, 4, 0, res_cb, "write");
    eio.write(last_fd, 'test\nfail\n', 4)
#      event_loop ();
    event_loop()
#
#      eio_read (last_fd, 0, 8, 0, EIO_PRI_DEFAULT, read_cb, "read");
    eio.read(last_fd, 8, 0, read_callback)
#      eio_readlink ("eio-test-dir/eio-symlink", 0, res_cb, "readlink");
    event_loop()
#
#      eio_dup2 (1, 2, EIO_PRI_DEFAULT, res_cb, "dup"); // dup stdout to stderr
    eio.dup2 (1, 2) # dup stdout to stderr
#      eio_chmod ("eio-test-dir", 0765, 0, res_cb, "chmod");
    eio.chmod('eio-test-dir', 0765)
#      eio_ftruncate (last_fd, 9, 0, res_cb, "ftruncate");
    eio.ftruncate(last_fd, 9)
#      eio_fdatasync (last_fd, 0, res_cb, "fdatasync");
    eio.fdatasync(last_fd)
#      eio_fsync (last_fd, 0, res_cb, "fsync");
    eio.fsync(last_fd)
#      eio_sync (0, res_cb, "sync");
    eio.sync()
#      eio_busy (0.5, 0, res_cb, "busy");
    eio.busy(0.5)
#      event_loop ();
    event_loop()
#
#      eio_sendfile (1, last_fd, 4, 5, 0, res_cb, "sendfile"); // write "test\n" to stdout
    eio.sendfile(1, last_fd, 4, 5) # write "test\n" to stdout
#      eio_fstat (last_fd, 0, stat_cb, "stat");
    eio.fstat(last_fd)
#      event_loop ();
    event_loop()
#
#      eio_truncate ("eio-test-dir/eio-test-file", 6, 0, res_cb, "truncate");
    eio.truncate('eio-test-dir/eio-test-file', 6)
#      eio_readahead (last_fd, 0, 64, 0, res_cb, "readahead");
    eio.readahead(last_fd, 0, 64)
#      event_loop ();
    event_loop()
#
#      eio_close (last_fd, 0, res_cb, "close");
    eio.close(last_fd)
#      eio_link ("eio-test-dir/eio-test-file", "eio-test-dir/eio-test-file-2", 0, res_cb, "link");
    eio.link('eio-test-dir/eio-test-file', 'eio-test-dir/eio-test-file-2')
#      event_loop ();
    event_loop()
#
#      eio_rename ("eio-test-dir/eio-test-file", "eio-test-dir/eio-test-file-renamed", 0, res_cb, "rename");
    eio.rename('eio-test-dir/eio-test-file', 'eio-test-dir/eio-test-file-renamed')
#      event_loop ();
    event_loop()
#
#      eio_unlink ("eio-test-dir/eio-fifo", 0, res_cb, "unlink");
    eio.unlink('eio-test-dir/eio-fifo')
#      eio_unlink ("eio-test-dir/eio-symlink", 0, res_cb, "unlink");
    eio.unlink('eio-test-dir/eio-symlink')
#      eio_unlink ("eio-test-dir/eio-test-file-2", 0, res_cb, "unlink");
    eio.unlink('eio-test-dir/eio-test-file-2')
#      eio_unlink ("eio-test-dir/eio-test-file-renamed", 0, res_cb, "unlink");
    eio.unlink('eio-test-dir/eio-test-file-renamed')
#      event_loop ();
    event_loop()
#
#      eio_rmdir ("eio-test-dir", 0, res_cb, "rmdir");
    eio.rmdir('eio-test-dir')
#      event_loop ();
    event_loop()
#    }
#  while (0);
#
#  return 0;
#}
#
print 'normally exiting\n'
