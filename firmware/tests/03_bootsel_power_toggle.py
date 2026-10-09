# Test 3 (board): BOOTSEL toggles the machine on/off with sense feedback.
# MicroPython for Raspberry Pi Pico 2 W. Run from Thonny (see the manual).

from machine import Pin
import rp2, time
sensor = Pin(26, Pin.IN, Pin.PULL_DOWN)
s = sensor.value()
ps_on = Pin(8, Pin.OUT, value=s)    # safe start: if the BC250 is on it stays on
state, t = ("ON" if s else "OFF"), time.ticks_ms()
print("Press BOOTSEL to power on")
while True:
    now, s = time.ticks_ms(), sensor.value()
    if state == "OFF" and rp2.bootsel_button():
        ps_on.value(1); state, t = "STARTING", now; print("Powering on")
    elif state == "STARTING":
        if s: state = "ON"; print("BC250 on")
        elif time.ticks_diff(now, t) > 10000:
            ps_on.value(0); state = "OFF"; print("It did not start: powering off")
    elif state == "ON" and not s:
        state, t = "SHUTTING_DOWN", now
    elif state == "SHUTTING_DOWN":
        if s: state = "ON"
        elif time.ticks_diff(now, t) > 3000:
            ps_on.value(0); state = "OFF"; print("Off: standby")
    time.sleep_ms(100)
