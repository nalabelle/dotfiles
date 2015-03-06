#!/bin/bash
if [[ $OSTYPE == "darwin"* ]]; then
  vm_stat | awk '/Pages free/{free=$3} /Pages active/{active=$3} /Pages inactive/{inactive=$3}/Pages speculative/{speculative=$3} /Pages wired down/{wired=$4} END { printf "%.0f\n", ((active + inactive + wired)/(free + active + inactive + speculative + wired)*100) }'
else
  awk '/MemTotal:/{total=$2} /MemFree:/{free=$2} END { printf "%.0f\n",((total-free)*100/total) }' /proc/meminfo
fi
