#import pyximport; pyximport.install()
import eio

def want_callback():
    print 'Want Called!'

def done_callback():
    print 'Done Called!'
    
eio.init(want_callback, done_callback)
eio.poll()

p = eio.mkdir("eio-test-dir", 0777, 0);

eio.poll()

