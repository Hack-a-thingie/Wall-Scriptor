#!/usr/bin/env python
import serial
import struct
import signal
import sys

# Set the number of samples per package
N =  128

ser = serial.Serial('/dev/ttyACM1', 115200)
out = open('data.csv', 'w')
out.write('pid, time, a0, a1, a2\n')

pid = 0
running = True

def signal_handler(signal, frame):
    global running
    running = False

signal.signal(signal.SIGINT, signal_handler)

def find_start(ser):
    counter = 0
    b = ser.read(1)
    # 10 is the number of expected 'S'
    while b != b'S' or counter < 10:
        if b == b'S':
            counter += 1
        else:
            counter = 0

        # We found 10 'S'
        if counter == 10:
            return
        b = ser.read(1)

def parse(ser, out):
    global pid
    print("Receiving package %d" % pid)
    for i in range(0, N):
        bdata = ser.read(10) # Binary data sizeof Data struct
        time, a0, a1, a2 = struct.unpack('Ihhh', bdata)
        out.write('%d, %d, %d, %d, %d\n' % (pid, time, a0, a1, a2))
    pid += 1

while running:
    find_start(ser)
    parse(ser, out)

out.close()
print("Terminating program")
