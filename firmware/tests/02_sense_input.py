# Test 2 (board): read the BC250 power-sense line on GP26.
# MicroPython for Raspberry Pi Pico 2 W. Run from Thonny (see the manual).

from machine import Pin
import time
ps_on = Pin(8, Pin.OUT, value=1)          # turns the PSU on
sensor = Pin(26, Pin.IN, Pin.PULL_DOWN)
while True:
    print("BC250 ON" if sensor.value() else "BC250 off")
    time.sleep(1)
