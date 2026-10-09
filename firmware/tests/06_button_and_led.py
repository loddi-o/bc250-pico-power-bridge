# Test 3 (button): LED breathes, full brightness while pressed.
# MicroPython for Raspberry Pi Pico 2 W. Run from Thonny (see the manual).

from machine import Pin, PWM
import math, time

button = Pin(10, Pin.IN, Pin.PULL_UP)
led = PWM(Pin(12), freq=1000)

def light(x):
    led.duty_u16(int(65535 * (1 - x)))

t = 0
while True:
    if button.value() == 0:           # pressed: steady at full
        light(1)
    else:                             # released: breathing
        light((1 - math.cos(t)) / 2)
        t += 0.05
    time.sleep(0.02)
