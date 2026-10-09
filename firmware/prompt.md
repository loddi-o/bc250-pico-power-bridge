# Firmware prompt

The firmware is not hand-written: it is generated with Claude Code (or any capable coding
assistant) as a fork of [awalol/DS5Dongle](https://github.com/awalol/DS5Dongle), the
Pico 2 W firmware that turns a DualSense into a low-latency wireless USB controller.
Paste the prompt below into Claude Code inside a clone of DS5Dongle.

Before flashing the generated firmware, run the MicroPython tests in [`tests/`](tests/)
to check the hardware (see the manual, part 1 step 12 and part 2 step 8).

---

```text
Fork github.com/awalol/DS5Dongle for the Raspberry Pi Pico 2 W and add a power
controller for the ATX power supply of an AMD BC250 board (running Bazzite).

Hardware
- GP8 (output, 8 mA drive) drives the LED of a PC817 optocoupler that pulls PS_ON to
  ground: level signal, GP8 high = PSU on.
- GP26 (input, internal pull-down) reads pin 9 of the TPMS1 header through 1 kOhm:
  high = BC250 on.
- GP10 (input, internal pull-up): momentary power button, pressed = 0.
  Software debounce 30 ms.
- GP12 (output, PWM 1 kHz): button LED, active low (duty 0 = full brightness).
  Keep it off for now, but provide a function to set its brightness 0..1.

Power logic
- With the machine off, when a paired DualSense connects, drive GP8 high. If GP26
  does not rise within 10 s, release GP8.
- With the machine on, read GP26 every 100 ms; if it stays low for 3 consecutive s,
  drive GP8 low and ignore controller connections for the next 15 s.
- At boot, if GP26 is already high, drive GP8 high at once and start in the ON state.
- Whenever the machine turns off, for any reason, disconnect all Bluetooth
  controllers (keep the pairings).

Button
- Machine off: any press powers it on (same path as a controller connection).
- Machine on, held for 4 s: forced power-off (GP8 low immediately, while the
  button is still down), then the 15 s pause.
- Machine on, double click (second press within 400 ms of the first release,
  each press shorter than 1 s): enter pairing mode for 30 s, exactly like BOOTSEL.
- Machine on, single click: no action (reserved for later).
- Presses between 1 and 4 s: no action.
- While powering on, and during the 15 s pause: ignore the button.
- A new controller paired while the machine is off powers the machine on when
  pairing completes.

Constraints
- All the power and button logic on core 1, watchdog enabled, no blocking waits
  on core 0.
- Do not change the existing Bluetooth, USB, audio, LED and BOOTSEL handling.
- First a minimal power-only version to test, then the integration with DS5Dongle.
```
