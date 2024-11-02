#!/bin/bash

# Dateipfade für die WAV-Dateien
PREP_BEEP="/home/martin/bin/HIIT/prep_beep.wav"
STOP_BEEP="/home/martin/bin/HIIT/stop_beep.wav"
INTERVAL_BEEP="/home/martin/bin/HIIT/interval_beep.wav"

# Funktion zum Abspielen der WAV-Dateien
function play_beep() {
    aplay "$1"  &>/dev/null
}

# Funktion für die Countdown-Anzeige
function countdown() {
    for ((i = "$1"; i > 0; i--)); do
        printf "\rNoch %02d Sekunden" "$i"
        sleep 1
    done
    printf "\r                          \r"
}

# Auswahl des Intervalls
clear
echo "Wählen Sie einen Intervall:"
echo "1) 40s Übung, 20s Pause"
echo "2) 45s Übung, 15s Pause"
echo "3) 50s Übung, 10s Pause"
echo "4) 60s Übung, 0s Pause"
read -rp "Ihre Auswahl (1-4): " choice

echo "In 10 Sekunden geht's los!"
sleep 10
clear

# Festlegen der Zeiten basierend auf der Auswahl
case "$choice" in
    1) work_time=40; rest_time=18 ;;
    2) work_time=45; rest_time=13 ;;
    3) work_time=50; rest_time=8 ;;
    4) work_time=60; rest_time=0 ;;
    *) echo "Ungültige Auswahl"; exit 1 ;;
esac

# Start-Beeps zur Vorbereitung
play_beep "$PREP_BEEP"
echo "Los geht's!"

# Timer-Schleife für insgesamt 9 Minuten
end_time=$((9 * 60))
elapsed=0
counter=0

while (( elapsed < end_time )); do
    ((counter++))

    # Vorbereitungs-Beep und Countdown für die Aktivitätseinheit
    echo "Runde $counter: Übungszeit: $work_time Sekunden"
    countdown "$work_time"
    elapsed=$((elapsed + work_time))

    # Abspielen des Beeps für die Pause oder das Intervall
    if (( counter % 3 == 0 )); then
        play_beep "$INTERVAL_BEEP"
    else
        play_beep "$STOP_BEEP"
    fi

    # Überprüfen, ob die Zeit abgelaufen ist
    if (( elapsed >= end_time )); then break; fi

    # Pause nur einfügen, wenn eine Pausezeit gesetzt ist
    if (( rest_time > 0 )); then
        echo "Pause: $rest_time Sekunden"
        countdown "$rest_time"
        elapsed=$((elapsed + rest_time))

        # Vorbereitungs-Beep für die nächste Aktivitätseinheit (wenn nicht die letzte Einheit)
        if (( elapsed < end_time )); then
            play_beep "$PREP_BEEP"
        fi
    fi
done

echo "Timer komplett beendet!"
