#import pyximport; pyximport.install()
import pdb; pdb.set_trace()

import eio
import time

def print_stats():
    print 'stats'
    print 'num reqs:\t', eio.nreqs()
    print 'num ready:\t', eio.nready()
    print 'num pending:\t', eio.npending()
    print 'num threads:\t', eio.nthreads()
    
def want_callback():
    print 'Want Called!'

def done_callback():
    print 'Done Called!'

print 'init', eio.init(want_callback, done_callback)

def mkdir_cb(foo):
    print 'mkdir callback', foo

#eio.mkdir("test/eio-test-dir", 0777, mkdir_cb)
eio.mkdir("test", 0777, mkdir_cb)
eio.mkdir("test/eio-test-dir", 0777, mkdir_cb)

eio.rmdir("test/eio-test-dir")
eio.rmdir("test")

print 'poll', eio.poll()

time.sleep(1)
print 'exiting'