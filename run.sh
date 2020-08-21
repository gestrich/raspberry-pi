#!/bin/zsh
set -e
set -u

TAG_NAME="pi-container"
PI_PROJECT_DIR="/home/pi"
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
  echo "STAGE: deploy start"
  docker run --name $TAG_NAME --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest ./run.sh buildSwift 
  pushToPi
  echo "STAGE: deploy done"
  #docker run --rm --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest pwd 
  #docker run --rm --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest swift build --build-path .build_linux
  #docker run --rm --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest swift build IOSVersions -c release
  #docker run --rm --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest swift build
  #docker run --rm bill-swift-hello-world:latest /bin/zsh ./build_swift.sh
  #scp .build/debug/raspberry-pi pi@192.168.1.217:/home/pi/HelloWorld
}

function pushToPi(){
  scp -i ~/.ssh/id_rsa -v raspberry-pi pi@192.168.1.217:$PI_PROJECT_DIR/HelloWorld
  scp -i ~/.ssh/id_rsa  -v run.sh pi@192.168.1.217:$PI_PROJECT_DIR/run.sh
  ssh pi@192.168.1.217 "$PI_PROJECT_DIR/run.sh runOnPi"
}

function runOnPi(){
 
  #These seem to be causing issues 
  #pkill -f bin/swift
  pkill -f HelloWorld ||

  LD_LIBRARY_PATH=/home/pi/usr/lib/swift/linux $PI_PROJECT_DIR/HelloWorld

#pkill -f run_script.sh;
# When running, `ps aux` will show: .build/armv6-unknown-linux-gnueabihf/debug/swift-test
  #/home/pi/usr/bin/swift run -j 1  
}  

function redeploy(){
  docker start $TAG_NAME --attach 
}

function buildSwift(){

  originalDir="$(pwd)"
  stagingDir="/test"
  echo "1"
  buildDir="$stagingDir/.build_linux"
  echo "2"
  rm -rf $stagingDir || echo "No staging directory to delete"
  mkdir $stagingDir || echo "Container exists"
  cp -r * $stagingDir
  cd $stagingDir

  mkdir $buildDir || echo "Couldn't create $buildDir. Maybe already exists"
  swift build --build-path $buildDir
  executablePath="$buildDir/debug/raspberry-pi"
  echo "Executable Path: $executablePath"
  echo "Original Dir: $originalDir"
  cp $executablePath $originalDir
  cp -r $buildDir $originalDir
  #cd /
  #mkdir test
  #git clone https://github.com/gestrich/raspberry-pi.git
  #cd raspberry-pi
  #swift build
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
