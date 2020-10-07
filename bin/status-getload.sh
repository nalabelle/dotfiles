#!/bin/bash
if [[ $OSTYPE == "darwin"* ]]; then
  sysctl vm.loadavg | awk '{ print $3, $4, $5 }'
else
  cut -d " " -f1-3 /proc/loadavg
fi
