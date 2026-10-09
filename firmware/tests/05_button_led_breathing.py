# Test 2 (button): breathing effect on the button LED (GP12, active low).
# MicroPython for Raspberry Pi Pico 2 W. Run from Thonny (see the manual).

from machine import Pin, PWM
import math, time

led = PWM(Pin(12), freq=1000)

def light(x):                         # x from 0 (off) to 1 (full)
    led.duty_u16(int(65535 * (1 - x)))  # active low: inverted

t = 0
while True:
    light((1 - math.cos(t)) / 2)
    t += 0.05
    time.sleep(0.02)
