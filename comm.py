#!/usr/bin/env python
import serial
import struct

ser = serial.Serial('/dev/ttyACM0', 115200)
read_byte = ser.read()

while read_byte is not None:
    read_byte = ser.read(12)
    fields = struct.unpack('Ihhhh', read_byte)
    print fields

