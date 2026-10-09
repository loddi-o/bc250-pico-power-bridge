# Test 1 (button): read the button contact on GP10.
# MicroPython for Raspberry Pi Pico 2 W. Run from Thonny (see the manual).

from machine import Pin
import time

button = Pin(10, Pin.IN, Pin.PULL_UP)   # pressed = 0

while True:
    print("pressed" if button.value() == 0 else "released")
    time.sleep(0.2)
