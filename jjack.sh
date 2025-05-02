#!/bin/bash

# CONFIGURATION
buffersize=1024
samplerate=44100
period=4

# CLEANUP

for i in {1..10}; do
  if aplay -l | grep -q '^card'; then
    break
  fi
  sleep 1
done


cleanup() {
  echo "Cleaning up..."
  pkill -f alsa_out
  pkill -f alsa_in
  pkill -f jackd
  pkill -f a2jmidid
}
trap cleanup EXIT

# DETECT PRIMARY SOUNDCARD (auto)
detect_primary_card() {
  local cards nonm8 rock
  mapfile -t cards < <(
    aplay -l | awk -F'[][]' '/^card/ {print $1}' \
    | sed -E 's/card ([0-9]+): (.*)/\1:\2/'
  )
  for entry in "${cards[@]}"; do
    local idx=${entry%%:*}
    local name=${entry#*:}
    [[ "$name" =~ M8 ]] && continue
    if [[ "$name" =~ [Rr]ockchip ]]; then
      rock+=("$idx")
    else
      nonm8+=("$idx")
    fi
  done

  if ((${#nonm8[@]})); then
    echo "${nonm8[0]},0"
    return
  fi
  if ((${#rock[@]})); then
    echo "${rock[0]},0"
    return
  fi
  echo "0,0"
}

# DETECT M8 SOUNDCARD (auto)
detect_m8_card() {
  while IFS= read -r entry; do
    local idx=${entry%%:*}
    local name=${entry#*:}
    if [[ "$name" =~ M8 ]]; then
      echo "${idx},0"
      return
    fi
  done < <(
    aplay -l | awk -F'[][]' '/^card/ {print $1}' \
    | sed -E 's/card ([0-9]+): (.*)/\1:\2/'
  )
  echo ""
}

primary_card=$(detect_primary_card)
echo "Auto-detected primary soundcard: $primary_card"

m8_card=$(detect_m8_card)
if [[ -z "$m8_card" ]]; then
  echo "Warning: M8 soundcard not found, defaulting to primary."
  m8_card=$primary_card
fi
 echo "Using M8 soundcard: $m8_card"

# START JACKD
if ! pgrep -x jackd &>/dev/null; then
  jackd -d alsa -d hw:$primary_card \
        -r "$samplerate" -p "$buffersize" -i 2 -o 2 &
  sleep 2
else
  echo "JACK server already running."
fi

# SETUP ALSA ↔ JACK
setup_bridge() {
  local tag=$1; local hw=$2
  alsa_in  -j "${tag}_in"  -d hw:$hw  -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
  alsa_out -j "${tag}_out" -d hw:$hw  -r "$samplerate" -p "$buffersize" -n "$period" -c 2 &
}
setup_bridge "Primary" "$primary_card"
setup_bridge "M8" "$m8_card"
sleep 1

# JACK CONNECTION FUNCTION
connect() {
  jack_connect "$1" "$2" 2>/dev/null || echo "Warning: $1 → $2 failed"
}
connect "M8_in:capture_1" system:playback_1
connect "M8_in:capture_2" system:playback_2
connect system:capture_1   "M8_out:playback_1"
connect system:capture_2   "M8_out:playback_2"

# MIDI BRIDGE
if ! pgrep -x a2jmidid &>/dev/null; then
  a2jmidid -e &
  sleep 1
fi

# AUTO-CONNECT MIDI
ctrl=$(jack_lsp | grep 'a2j:.*capture' | grep -vE '(Midi Through|M8)' | head -n1)
m8p=$(jack_lsp | grep 'a2j:.*playback' | grep M8 | head -n1)
if [[ -n "$ctrl" && -n "$m8p" ]]; then
  echo "Connecting MIDI: $ctrl → $m8p"
  jack_connect "$ctrl" "$m8p" || echo "Warning: MIDI connect failed"
else
  echo "MIDI ports not found. Controller: $ctrl, M8: $m8p"
fi

# KEEP SCRIPT ALIVE
tail -f /dev/null

