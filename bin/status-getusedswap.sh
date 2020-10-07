#!/bin/bash
if [[ $OSTYPE == "darwin"* ]]; then
  sysctl vm.swapusage | awk '{print $4, $7, $10}' | sed 's/M//g' | awk '{ printf "%.0f\n",(($2/$1)*100) }'
else
  awk '/SwapTotal:/{total=$2} /SwapFree:/{free=$2} END { if (total > 0) { printf "%.0f\n",((total-free)*100/total) } else { printf "-\n" } }' /proc/meminfo
fi
