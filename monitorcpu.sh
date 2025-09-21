#!/bin/bash



WARN=80

ALERT=95

EMAIL="playplaystore330@gmail.com"

INTERVAL=10

ALERT_REPEAT=300



LAST_ALERT_TIME=0



# Clean exit on CTRL+C

trap "echo 'Stopping CPU monitor...'; exit 0" SIGINT SIGTERM



get_cpu_usage() {

CPU=($(head -n1 /proc/stat))

IDLE1=${CPU[4]}

TOTAL1=0

for VALUE in "${CPU[@]:1}"; do

TOTAL1=$((TOTAL1 + VALUE))

done

sleep 1

CPU=($(head -n1 /proc/stat))

IDLE2=${CPU[4]}

TOTAL2=0

for VALUE in "${CPU[@]:1}"; do

TOTAL2=$((TOTAL2 + VALUE))

done

IDLE=$((IDLE2 - IDLE1))

TOTAL=$((TOTAL2 - TOTAL1))

CPU=$(( (100 * (TOTAL - IDLE)) / TOTAL ))

echo $CPU

}



while true

do

CPU_INT=$(get_cpu_usage)

CURRENT_TIME=$(date +%s)



if [ "$CPU_INT" -ge "$ALERT" ]; then

MESSAGE="CRITICAL ALERT: CPU usage is at $CPU_INT%"

echo "$MESSAGE" | mail -s "CPU ALERT" "$EMAIL"



if [ $((CURRENT_TIME - LAST_ALERT_TIME)) -ge $ALERT_REPEAT ]; then

zenity --error --title="CPU ALERT" --text="$MESSAGE"

LAST_ALERT_TIME=$CURRENT_TIME

fi



elif [ "$CPU_INT" -ge "$WARN" ]; then

MESSAGE="WARNING: CPU usage is at $CPU_INT%"

echo "$MESSAGE" | mail -s "CPU WARNING" "$EMAIL"



# run in background so it doesn't block

( zenity --warning --title="CPU WARNING" --text="$MESSAGE" --ok-label="Cancel" ) &

fi



sleep $INTERVAL

done 
