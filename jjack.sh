#!/bin/bash

# CONFIGURATION
soundcard1="0,0"        # rockchip,rk817-codec
soundcard2="1,0"        # M8 (use 7,0 if needed)
midi_controller="YourControllerName"  # Set from `aconnect -l`
m8_midi="M8"
buffersize=1024
samplerate=44100
period=4

# CLEANUP
cleanup() {
  echo "Cleaning up..."
  pkill -f alsa_out
  pkill -f alsa_in
  pkill -f jackd
  pkill -f a2jmidid
}
trap cleanup EXIT

# START JACKD IF NOT RUNNING
if pgrep -x jackd >/dev/null; then
  echo "JACK server already running."
else
  jackd -d alsa -d hw:${soundcard1} -r "$samplerate" -p "$buffersize" &
  sleep 2
fi

# SETUP SOUND CARD 1 (rk817)
if aplay -l | grep -q "rockchip,rk817-codec"; then
  echo "rk817 codec detected, connecting..."
  alsa_in -j "rk817_in" -d hw:${soundcard1} -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
  alsa_out -j "rk817_out" -d hw:${soundcard1} -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
else
  echo "rk817 codec not detected, skipping."
fi

# SETUP SOUND CARD 2 (M8)
alsa_in -j "M8_in" -d hw:${soundcard2} -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
alsa_out -j "M8_out" -d hw:${soundcard2} -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
sleep 1

# FUNCTION TO CONNECT JACK PORTS IF AVAILABLE
connect_if_possible() {
  if jack_lsp | grep -q "$1" && jack_lsp | grep -q "$2"; then
    jack_connect "$1" "$2" 2>/dev/null || echo "Warning: Failed to connect $1 -> $2"
  fi
}

# JACK AUDIO ROUTING
connect_if_possible "M8_in:capture_1" system:playback_1
connect_if_possible "M8_in:capture_2" system:playback_2
connect_if_possible system:capture_1 "M8_out:playback_1"
connect_if_possible system:capture_2 "M8_out:playback_2"

# MIDI BRIDGE SETUP
if ! pgrep -x a2jmidid >/dev/null; then
  a2jmidid -e &
  sleep 1
else
  echo "a2jmidid already running."
fi

# CONNECT MIDI CONTROLLER IF NAMES SET
if [ -n "$midi_controller" ] && [ -n "$m8_midi" ]; then
  controller_port=$(jack_lsp | grep -m1 "a2j:${midi_controller}.*capture")
  m8_port=$(jack_lsp | grep -m1 "a2j:${m8_midi}.*playback")

  if [ -n "$controller_port" ] && [ -n "$m8_port" ]; then
    echo "Connecting MIDI: $controller_port → $m8_port"
    jack_connect "$controller_port" "$m8_port"
  else
    echo "MIDI ports not found. Controller: $controller_port, M8: $m8_port"
  fi
else
  echo "MIDI controller or M8 MIDI name not set. Skipping MIDI connection."
fi

# KEEP SCRIPT ALIVE
tail -f /dev/null
