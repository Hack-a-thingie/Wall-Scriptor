#!/usr/bin/env python
import serial
import struct

N = 10

ser = serial.Serial('/dev/ttyACM1', 115200)
out = open('data.csv', 'w')
out.write('time, a0, a1, a2\n')

def find_start(ser):
    counter = 0
    b = ser.read(1)
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
    for i in range(0, N):
        bdata = ser.read(10) # Binary data
        data = struct.unpack('Ihhh', bdata)
        out.write('%d, %d, %d, %d\n' % data)

counter = 0
while counter < 10:
    find_start(ser)
    parse(ser, out)
    counter += 1

out.close()
