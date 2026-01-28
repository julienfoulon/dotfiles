#!/bin/sh

if ! command -v powerprofilesctl >/dev/null 2>&1; then
  exit 0
fi

info=$(powerprofilesctl 2>/dev/null) || exit 0
driver=$(printf "%s\n" "$info" | awk -F': ' '/Driver:/ {print $2; exit}')

if [ -z "$driver" ] || [ "$driver" = "placeholder" ]; then
  exit 0
fi

profile=$(printf "%s\n" "$info" | awk -F': ' '/Profile:/ {print $2; exit}')
if [ -z "$profile" ]; then
  profile=$(powerprofilesctl get 2>/dev/null)
fi

icon=""
case "$profile" in
  performance) icon="" ;;
  balanced) icon="" ;;
  power-saver) icon="" ;;
esac

tooltip="Power profile: $profile\nDriver: $driver"
tooltip=$(printf "%s" "$tooltip" | sed 's/"/\\"/g')

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tooltip" "$profile"
