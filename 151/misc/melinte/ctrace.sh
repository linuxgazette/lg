#!/bin/sh

# 
# 
# 

export CTRACE_PROGRAM="$1"
LD_PRELOAD=./libctrace.so "$1" 

