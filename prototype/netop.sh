#!/bin/bash
# netop.sh - watch hotspot (Wi-Fi) traffic, log top talkers, alert when it's high.
#
# Usage: ./netop.sh [interval_sec] [alert_KBps]
#   interval_sec  sample length in seconds          (default 30)
#   alert_KBps    notify when download+upload > this (default 500)
#
# Log: ~/Library/Logs/netop.log   (tail -f it, or grep for ALERT)
# No sudo needed.

INTERVAL=${1:-30}
ALERT_KBPS=${2:-500}
TOP_N=5
LOG="$HOME/Library/Logs/netop.log"
COOLDOWN=600          # seconds between notifications
last_alert=0

iface() { route -n get default 2>/dev/null | awk '/interface:/ {print $2}'; }
bytes() { netstat -ibn -I "$1" | awk '$3 ~ /Link/ {print $7, $10; exit}'; }
kbps()  { echo $(( $1 / INTERVAL / 1024 )); }

echo "netop: every ${INTERVAL}s, alert > ${ALERT_KBPS} KB/s, log -> $LOG"

while true; do
  IF=$(iface)
  if [ -z "$IF" ]; then sleep "$INTERVAL"; continue; fi
  read -r i1 o1 < <(bytes "$IF")

  # nettop -d prints cumulative totals first, then deltas for the interval; keep the deltas.
  top=$(nettop -P -d -L 2 -s "$INTERVAL" -t wifi -J bytes_in,bytes_out -x 2>/dev/null \
        | awk -F, '/bytes_in/ {n++; next} n==2 && ($2+$3)>0 {print $2+$3, $2, $3, $1}' \
        | sort -rn | head -"$TOP_N")

  read -r i2 o2 < <(bytes "$IF")
  in_k=$(kbps $((i2 - i1)))
  out_k=$(kbps $((o2 - o1)))
  total=$((in_k + out_k))
  ts=$(date '+%F %T')

  tag="     "; [ "$total" -gt "$ALERT_KBPS" ] && tag="ALERT"
  {
    printf '%s %s %-4s in=%6d KB/s out=%6d KB/s\n' "$ts" "$tag" "$IF" "$in_k" "$out_k"
    echo "$top" | awk -v s="$INTERVAL" 'NF {
      name=$4; for (i=5; i<=NF; i++) name=name" "$i
      sub(/\.[0-9]+$/, "", name)
      printf "      %6d KB/s in %6d KB/s out  %s\n", $2/s/1024, $3/s/1024, name }'
  } | tee -a "$LOG"

  now=$(date +%s)
  if [ "$tag" = "ALERT" ] && [ $((now - last_alert)) -ge "$COOLDOWN" ]; then
    who=$(echo "$top" | head -1 | awk '{name=$4; for(i=5;i<=NF;i++) name=name" "$i; sub(/\.[0-9]+$/,"",name); print name}')
    osascript -e "display notification \"${total} KB/s on ${IF} — top: ${who}\" with title \"netop: high network usage\"" 2>/dev/null
    last_alert=$now
  fi
done
