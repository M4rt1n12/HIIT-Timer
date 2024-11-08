#!/bin/bash

# File paths for the WAV files
PFAD="/home/martin/bin/HIIT"
PREP_BEEP="$PFAD/prep_beep.wav"
STOP_BEEP="$PFAD/stop_beep.wav"
INTERVAL_BEEP="$PFAD/interval_beep.wav"

# Function to play the WAV files
function play_beep() {
    # Get the current volume
    current_volume=$(amixer get Master | grep -oP '\d+(?=%)' | head -n 1)

    # Set volume to 75%
    amixer set Master 35%

    # Play the audio file
    aplay "$1" &>/dev/null

    # Restore the original volume
    amixer set Master "${current_volume}%"
}

# Function for the countdown display
function countdown() {
    for ((i = "$1"; i > 0; i--)); do
        printf "\rRemaining %02d seconds" "$i"
        sleep 1
    done
    printf "\r                          \r"
}

# Interval selection
clear
echo "Choose an interval:"
echo "1) 40s exercise, 20s rest"
echo "2) 45s exercise, 15s rest"
echo "3) 50s exercise, 10s rest"
echo "4) 60s exercise, 0s rest"
read -rp "Your choice (1-4): " choice

echo "Starting in 10 seconds!"
sleep 10
clear

# Setting the times based on the selection
case "$choice" in
    1) work_time=40; rest_time=18 ;;
    2) work_time=45; rest_time=13 ;;
    3) work_time=50; rest_time=8 ;;
    4) work_time=60; rest_time=0 ;;
    *) echo "Invalid selection"; exit 1 ;;
esac

# Start beeps for preparation
play_beep "$PREP_BEEP"
echo "Let's go!"

# Timer loop for a total of 9 minutes
end_time=$((9 * 60))
elapsed=0
counter=0

while (( elapsed < end_time )); do
    ((counter++))

    # Preparation beep and countdown for the activity unit
    echo "Round $counter: Exercise time: $work_time seconds"
    countdown "$work_time"
    elapsed=$((elapsed + work_time))

    # Play the beep for the rest or the interval
    if (( counter % 3 == 0 )); then
        play_beep "$INTERVAL_BEEP"
    else
        play_beep "$STOP_BEEP"
    fi
    if (( counter == 9 )); then
        play_beep "$INTERVAL_BEEP"
        break
    fi

    # Check if the time is up
    if (( elapsed >= end_time )); then break; fi

    # Only include a rest if a rest time is set
    if (( rest_time > 0 )); then
        echo "Rest: $rest_time seconds"
        countdown "$rest_time"
        elapsed=$((elapsed + rest_time))

        # Preparation beep for the next activity unit (if not the last unit)
        if (( elapsed < end_time )); then
            play_beep "$PREP_BEEP"
        fi
    fi
done

echo "Timer completed!"
