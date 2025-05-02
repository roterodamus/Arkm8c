#!/bin/bash

# CONFIGURATION
primary_card_manual=""       # Set to e.g. "2,0" to override auto-detection
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

# DETECT PRIMARY SOUNDCARD (if not set manually)
detect_primary_card() {
  for card_index in $(aplay -l | grep '^card' | awk -F':' '{print $1}' | awk '{print $2}' | sort -n); do
    if ! aplay -l | grep -A1 "^card $card_index" | grep -q "M8"; then
      echo "$card_index,0"
      return
    fi
  done
  echo "0,0"  # fallback
}

if [ -n "$primary_card_manual" ]; then
  primary_card="$primary_card_manual"
  echo "Using manually set primary soundcard: $primary_card"
else
  primary_card=$(detect_primary_card)
  echo "Auto-detected primary soundcard: $primary_card"
fi

m8_card="1,0"
echo "Using M8 soundcard: $m8_card"

# START JACKD
if pgrep -x jackd >/dev/null; then
  echo "JACK server already running."
else
  jackd -d alsa -d hw:$primary_card -r "$samplerate" -p "$buffersize" &
  sleep 2
fi

# SETUP AUDIO INTERFACES
alsa_in -j "Primary_in" -d hw:$primary_card -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
alsa_out -j "Primary_out" -d hw:$primary_card -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &

alsa_in -j "M8_in" -d hw:$m8_card -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
alsa_out -j "M8_out" -d hw:$m8_card -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
sleep 1

# JACK CONNECTION FUNCTION
connect_if_possible() {
  if jack_lsp | grep -q "$1" && jack_lsp | grep -q "$2"; then
    jack_connect "$1" "$2" 2>/dev/null || echo "Warning: Failed to connect $1 → $2"
  fi
}

# AUDIO ROUTING
connect_if_possible "M8_in:capture_1" system:playback_1
connect_if_possible "M8_in:capture_2" system:playback_2
connect_if_possible system:capture_1 "M8_out:playback_1"
connect_if_possible system:capture_2 "M8_out:playback_2"

# MIDI BRIDGE
if ! pgrep -x a2jmidid >/dev/null; then
  a2jmidid -e &
  sleep 1
fi

# AUTO-CONNECT FIRST AVAILABLE CONTROLLER TO M8
controller_port=$(jack_lsp | grep -m1 "a2j:.*capture")
m8_port=$(jack_lsp | grep -m1 "a2j:M8.*playback")

if [ -n "$controller_port" ] && [ -n "$m8_port" ]; then
  echo "Connecting MIDI: $controller_port → $m8_port"
  jack_connect "$controller_port" "$m8_port"
else
  echo "MIDI ports not found. Controller: $controller_port, M8: $m8_port"
fi

# KEEP SCRIPT ALIVE
tail -f /dev/null
