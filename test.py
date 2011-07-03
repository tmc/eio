#import pyximport; pyximport.install()

import os
import eio
import time
import unittest

def print_stats():
    print '\tstats:'
    print '\t\tnum reqs:\t', eio.nreqs()
    print '\t\tnum ready:\t', eio.nready()
    print '\t\tnum pending:\t', eio.npending()
    print '\t\tnum threads:\t', eio.nthreads()
    
def want_callback():
    print 'Want Called!'

def done_callback():
    print 'Done Called!'

print eio.init(want_callback, done_callback)

class TestDirectoryOperations(unittest.TestCase):
    
    def setUp(self):
        print 'setup'
        print_stats()

    def tearDown(self):
        print 'setup'
        print_stats()

    def test_mkdir(self):
        def mkdir_cb(foo):
            print 'mkdir callback', foo
        
        d1 = 'test'
        d2 = 'test/eio-test-dir'

        # ensure dirs don't exist:
        if os.path.exists(d2):
            os.rmdir(d2)
        if os.path.exists(d1):
            os.rmdir(d1)

        self.assertFalse(os.path.exists(d1))
        eio.mkdir(d1, 0777, mkdir_cb)
        time.sleep(0.1)
        print 'poll', eio.poll()
        self.assertTrue(os.path.exists(d1))

        self.assertFalse(os.path.exists(d2))
        eio.mkdir(d2, 0777, mkdir_cb)
        time.sleep(2.1)
        print 'poll', eio.poll()
        self.assertTrue(os.path.exists(d2))
        
        eio.rmdir(d2)
        self.assertFalse(os.path.exists(d2))
        eio.rmdir(d1)
        self.assertFalse(os.path.exists(d1))



print 'poll', eio.poll()
time.sleep(0.1)
print 'exiting'