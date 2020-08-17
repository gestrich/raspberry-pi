#!/bin/zsh
set -e
set -u

function buildDockerImage(){
  #Build Docker image initially
  #docker build -t bill-swift-hello-world -f Dockerfile .
  ssh_key="$(cat ~/.ssh/id_rsa)"
  echo "$ssh_key"
  DOCKER_BUILDKIT=1 docker build -t bill-swift-hello-world -f Dockerfile --build-arg SSH_PRIVATE_KEY="$ssh_key" .
}

#Had to run ssh-add
function deploy(){
  #docker run -ti b305f265035b /bin/bash
  #WORKDIR /app
  #COPY . ./
  #RUN swift build --jobs 1
  #COPY --from=build /app/.build/debug/raspberry-pi output
  #cd /app

  #DOCKER_BUILDKIT=1 docker build --ssh default -t bill-swift-hello-world -f Dockerfile .
  #docker build -t bill-swift-hello-world -f Dockerfile .
  #docker run --rm --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest swift build 
  #docker run --rm --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest ls 
  #docker run --rm --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest swift build --build-path .build_linux
  docker run --rm bill-swift-hello-world:latest /bin/zsh ./build_swift.sh
  #scp .build/debug/raspberry-pi pi@192.168.1.217:/home/pi/HelloWorld
} 

function buildSwift(){
  cd /
  mkdir test
  git clone https://github.com/gestrich/raspberry-pi.git
  cd raspberry-pi
  swift build
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
