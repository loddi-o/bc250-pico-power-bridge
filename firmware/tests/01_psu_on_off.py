# Test 1 (board): PSU turns on for 10 s via GP8, then back to standby.
# MicroPython for Raspberry Pi Pico 2 W. Run from Thonny (see the manual).

from machine import Pin
import time
ps_on = Pin(8, Pin.OUT, value=0)
ps_on.value(1)          # the PSU must start (fan)
print("PSU on")
time.sleep(10)
ps_on.value(0)          # it must go back to standby
print("PSU in standby")
