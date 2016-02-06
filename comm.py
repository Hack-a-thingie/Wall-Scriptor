#!/usr/bin/env python
# Uses python3 and the pyserial package
import serial
import struct

ser = serial.Serial('/dev/ttyACM0', 115200)
ser.write([10]);
read_byte = ser.read()

while read_byte is not None:
    read_byte = ser.read(12)
    fields = struct.unpack('Ihhhh', read_byte)
    print(fields)

