#!/bin/bash
if [[ $OSTYPE == "darwin"* ]]; then
  sysctl vm.loadavg | awk '{ print $3 }'
else
  cut -d " " -f1 /proc/loadavg
fi
