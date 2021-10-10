import serial
import code
import time

import sys

console = sys.argv[1]

def sar(s, text, line_limit=1):
    ser.flushInput()
    ser.flushOutput()
    s.write(text)
    num_of_lines = 0
    while True:
        response = ser.readline()
        print(response)

        num_of_lines = num_of_lines + 1

        if num_of_lines == line_limit:
            break

ser = serial.Serial(console, timeout=1)  # open serial port
ser.baudrate = 115200

print("1 --------------------------------->")
sar(ser, b"ansi\r", 25)
time.sleep(0.5)
print("2 --------------------------------->")
sar(ser, b"\r", 3)
time.sleep(0.5)
print("3 --------------------------------->")
sar(ser, b"\r", 3)
time.sleep(0.5)
print("4 --------------------------------->")
sar(ser, b"\r", 3)
time.sleep(0.5)
print("5 --------------------------------->")
sar(ser, b"\r", 3)
time.sleep(0.5)
print("6 --------------------------------->")
sar(ser, b"\r", 2)
time.sleep(0.5)
print("7 --------------------------------->")
sar(ser, b"\r", 2)
time.sleep(0.5)
print("8 --------------------------------->")
sar(ser, b"2 \r", 2)
time.sleep(0.5)
print("9 --------------------------------->")
sar(ser, b"\t\r", 15)
time.sleep(15)
print("10  --------------------------------->")
sar(ser, b"\r", 3)
time.sleep(0.5)
print("11 --------------------------------->")
sar(ser, b"\r", 2)
time.sleep(0.5)
print("12 --------------------------------->")
sar(ser, b"\r", 5)




