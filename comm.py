#!/usr/bin/env python
import serial
import struct

ser = serial.Serial('/dev/ttyACM1', 115200)
out = open('data.csv', 'wb')

counter = 0
while counter < 100000:
    line = ser.readline()
    out.write(line)
    counter += 1

out.close()
