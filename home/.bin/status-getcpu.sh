#!/bin/bash
getconf _NPROCESSORS_ONLN

#if [[ $OSTYPE == "darwin"* ]]; then
#  sysctl -n hw.ncpu
#else
#  grep -c ^processor /proc/cpuinfo
#fi
