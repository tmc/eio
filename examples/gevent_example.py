"""
Example showing eio io lib works in a greened (gevent) environment.
"""
import os
import eio
import gevent
from gevent.event import Event
from gevent.socket import wait_read


def show_nonblocking():
    while True:
        gevent.sleep(0.1)
        print 'not blocking!'

## eio utilities

# pipe used for cross thread signalling
respipe = os.pipe()

def poll_eio():
    while True:
        wait_read(respipe[0])
        while eio.nreqs():
            eio.poll()
            gevent.sleep()

def want_poll():
    os.write(respipe[1], ' ')

def done_poll():
    os.read(respipe[0], 1)

def do_io(n_megs, use_eio=False):
    
    r = os.open('/dev/urandom', os.O_RDONLY)
    
    print '\nreading %s megs from /dev/urandom' % n_megs
    
    if use_eio:
        eio.init(want_poll, done_poll)

        r_event = Event()
        def set_r_event(result):
            r_event.set()

        buf = eio.read(r, 1024*1024*n_megs, 0, set_r_event)

        print 'waiting'
        r_event.wait()
    else:
        buf = os.read(r, 1024*1024*n_megs)
    print '\ndone.'
    
    gevent.sleep(0.5)


if __name__ == '__main__':
    import sys
    num_megs = 50
    use_eio = False

    if len(sys.argv) > 1:
        use_eio = sys.argv[1] == 'eio'
        if len(sys.argv) > 2:
            try:
                num_megs = int(sys.argv[2])
            except ValueError:
                pass

    if use_eio:
        print 'using eio calls'
    else:
        print 'using traditional stdlib os calls, run as `%s eio` to use eio calls' % sys.argv[0]

    gevent.spawn(show_nonblocking)
    gevent.spawn(poll_eio)
    gevent.spawn(do_io, num_megs, use_eio).join()

