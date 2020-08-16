#!/bin/zsh
set -e
set -u

function buildDockerImage(){
  #Build Docker image initially
  docker build -t bill-swift-hello-world -f Dockerfile .
}

function deploy(){
  #docker run -ti b305f265035b /bin/bash
  docker run -ti bill-swift-hello-world:latest /bin/bash
  scp .build/debug/raspberry-pi pi@192.168.1.217:/home/pi/HelloWorld
} 

#To Run on Device
#LD_LIBRARY_PATH=/home/pi/usr/lib/swift/linux ./HelloWorld


# Check if the function exists
  if [ $# -gt 0 ]; then 
#if declare -f "$1" > /dev/null
  # call arguments verbatim
  "$@"
else
  # Show a helpful error
  echo "Functions Available:"
  typeset -f | awk '!/^main[ (]/ && /^[^ {}]+ *\(\)/ { gsub(/[()]/, "", $1); print $1}'
  exit 1
fi
