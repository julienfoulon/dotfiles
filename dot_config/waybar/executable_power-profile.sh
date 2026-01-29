#!/bin/sh

if ! command -v powerprofilesctl >/dev/null 2>&1; then
  exit 0
fi

run_powerprofilesctl() {
  if [ -x /usr/bin/python3 ] && [ -x /usr/bin/powerprofilesctl ]; then
    /usr/bin/python3 /usr/bin/powerprofilesctl "$@"
  else
    powerprofilesctl "$@"
  fi
}

info=$(run_powerprofilesctl 2>/dev/null) || exit 0
profile=$(printf "%s\n" "$info" | awk -F': ' '/Profile:/ {print $2; exit}')
if [ -z "$profile" ]; then
  profile=$(run_powerprofilesctl get 2>/dev/null) || exit 0
fi

if [ "$1" = "toggle" ]; then
  profiles=$(printf "%s\n" "$info" | awk '
    /^[* ]*[a-z-]+:$/ {
      line=$0
      sub(/^[* ]+/, "", line)
      sub(/:$/, "", line)
      print line
    }
  ')
  if [ -z "$profiles" ]; then
    profiles="performance balanced power-saver"
  fi

  next=""
  found=0
  for p in $profiles; do
    if [ "$found" -eq 1 ]; then
      next=$p
      break
    fi
    if [ "$p" = "$profile" ]; then
      found=1
    fi
  done
  if [ -z "$next" ]; then
    for p in $profiles; do
      next=$p
      break
    done
  fi

  [ -n "$next" ] || exit 0
  run_powerprofilesctl set "$next" 2>/dev/null || exit 0
  exit 0
fi

driver=$(printf "%s\n" "$info" | awk -F':\t*' '
  /Driver:/ {
    sub(/^[^:]*:\t*/, "", $0)
    if ($0 != "placeholder") {
      print $0
      exit
    }
  }
')
if [ -z "$driver" ]; then
  driver=$(printf "%s\n" "$info" | awk -F':\t*' '
    /^[* ]*[a-z-]+:/ {section=$1; sub(/^[* ]+/, "", section); sub(/:$/, "", section)}
    /CpuDriver:/ {sub(/^[^:]*:\t*/, "", $0); cpu=$0}
    /PlatformDriver:/ {sub(/^[^:]*:\t*/, "", $0); plat=$0}
    END {
      if (cpu || plat) {
        if (cpu && plat) {
          printf "cpu=%s, platform=%s\n", cpu, plat
        } else if (cpu) {
          printf "cpu=%s\n", cpu
        } else {
          printf "platform=%s\n", plat
        }
      }
    }
  ')
fi
if [ -z "$driver" ]; then
  driver="unknown"
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
