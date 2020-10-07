#!/bin/bash
# mostly from here: http://ficate.com/blog/2012/10/15/battery-life-in-the-land-of-tmux/
# might be some from here eventually: https://raw.github.com/richo/battery/master/bin/battery

HEART='♥'
LIGHTNING='Ϟ'
SLOTS=5

if [[ $OSTYPE == "darwin"* ]]; then
  battery_info=`ioreg -rc AppleSmartBattery`
  on_external=$(echo $battery_info | grep -o '"ExternalConnected" = [A-Za-z]\+' | awk '{print $3}')
  current_charge=$(echo $battery_info | grep -o '"CurrentCapacity" = [0-9]\+' | awk '{print $3}')
  total_charge=$(echo $battery_info | grep -o '"MaxCapacity" = [0-9]\+' | awk '{print $3}')
else
  if [ -f /proc/acpi/battery ]; then
    current_charge=$(cat /proc/acpi/battery/BAT1/state | grep 'remaining capacity' | awk '{print $3}')
    total_charge=$(cat /proc/acpi/battery/BAT1/info | grep 'last full capacity' | awk '{print $4}')
  else
    current_charge=0
    total_charge=0
    on_external="Yes"
  fi
fi

if [[ $on_external == "Yes" ]]; then
  echo -n "#[fg=white]$LIGHTNING "
  exit 0
fi

charged_slots=$(echo "(($current_charge/$total_charge)*$SLOTS)+1" | bc -l | cut -d '.' -f 1)
if [[ $charged_slots -gt $SLOTS ]]; then
  charged_slots=$SLOTS
fi

echo -n '#[fg=red]'
for i in `seq 1 $charged_slots`; do echo -n "$HEART"; done

if [[ $charged_slots -lt $SLOTS ]]; then
  echo -n '#[fg=white]'
  for i in `seq 1 $(echo "$SLOTS-$charged_slots" | bc)`; do echo -n "$HEART"; done
fi
echo -n ' '
