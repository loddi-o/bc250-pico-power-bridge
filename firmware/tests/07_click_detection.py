# Test 4 (button): single / double click and 4 s long-press detection.
# MicroPython for Raspberry Pi Pico 2 W. Run from Thonny (see the manual).

from machine import Pin
import time

button = Pin(10, Pin.IN, Pin.PULL_UP)
DEBOUNCE = 30       # ms
SHORT = 1000        # ms: beyond this it is no longer a click
DOUBLE = 400        # ms between the first release and the second press
LONG = 4000         # ms: forced power-off

prev = False; t_change = 0; t_down = 0; t_up = 0
clicks = 0; long_done = False

while True:
    now = time.ticks_ms()
    p = button.value() == 0
    if p != prev and time.ticks_diff(now, t_change) > DEBOUNCE:
        prev = p; t_change = now
        if p:                                   # pressed
            t_down = now; long_done = False
        elif not long_done:                     # released
            if time.ticks_diff(now, t_down) < SHORT:
                clicks += 1; t_up = now
                if clicks == 2:
                    print("double click -> pairing"); clicks = 0
            else:
                print("medium press -> no action"); clicks = 0
    if p and not long_done and time.ticks_diff(now, t_down) >= LONG:
        print("held 4 s -> forced power-off"); long_done = True; clicks = 0
    if clicks == 1 and not p and time.ticks_diff(now, t_up) > DOUBLE:
        print("single click -> reserved"); clicks = 0
    time.sleep_ms(5)
