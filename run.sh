#!/bin/zsh
set -e
set -u

TAG_NAME="pi-container"
PI_PROJECT_DIR="/home/pi"
EXECUTABLE_NAME="pi"
buildDirName=".build_linux"

#Shell into docker
#docker run --rm -ti --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest /bin/bash

function buildDockerImage(){
  #Build Docker image initially
  #docker build -t bill-swift-hello-world -f Dockerfile .
  ssh_key="$(cat ~/.ssh/id_rsa)"
  echo "$ssh_key"
  DOCKER_BUILDKIT=1 docker build -t bill-swift-hello-world -f Dockerfile --build-arg SSH_PRIVATE_KEY="$ssh_key" .
}

#Had to run ssh-add
function deploy(){
  echo "STAGE: deploy start"
  #docker stop $TAG_NAME
  #docker rm $TAG_NAME
  #docker run --name $TAG_NAME --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest ./run.sh buildSwift 
  #docker run --name $TAG_NAME --volume "$(pwd)/:/app/src"  --workdir "/app/src/" bill-swift-hello-world:latest ./run.sh buildSwift 
  #docker run --volume "$(pwd)/:/app/src"  --workdir "/app/src/" bill-swift-hello-world:latest ./run.sh buildSwift 
  docker run --rm --volume "$(pwd)/:/src"  --workdir "/src/" bill-swift-hello-world:latest ./run.sh buildSwift
  stopPi
  pushToPi
  runPi
  echo "STAGE: deploy done"
}

function redeploy(){
  #This seems to run the `docker run` command again?
  ssh pi@192.168.1.217 "$PI_PROJECT_DIR/run.sh pi_stop"
  docker start $TAG_NAME --attach
}

function stopPi(){
  echo "STAGE: Stopping Pi"
  ssh pi@192.168.1.217 "$PI_PROJECT_DIR/run.sh pi_stop" || 
  echo "STAGE: Stopping Pi done"
}

function pushToPi(){
  echo "STAGE: Push to Pi"
  scp -i ~/.ssh/id_rsa $buildDirName/debug/raspberry-pi pi@192.168.1.217:$PI_PROJECT_DIR/$EXECUTABLE_NAME
  scp -i ~/.ssh/id_rsa run.sh pi@192.168.1.217:$PI_PROJECT_DIR/run.sh
  echo "STAGE: Push to Pi done"
}

function runPi(){
  echo "STAGE: Running Pi"
  ssh -tt pi@192.168.1.217 "$PI_PROJECT_DIR/run.sh pi_run"
  echo "STAGE: Running Pi done"
}  

function pi_run(){
  LD_LIBRARY_PATH=/home/pi/usr/lib/swift/linux $PI_PROJECT_DIR/$EXECUTABLE_NAME
}

function pi_stop(){
  pkill -f -x $EXECUTABLE_NAME ||
  sleep 1 
}  

function buildSwift(){

  #originalDir="$(pwd)"
  #stagingDir="/test"
  #buildDir="$stagingDir/$buildDirName"
  #echo ".build_linux contents: $(ls .build_linux)"
  #rm -rf $stagingDir || echo "No staging directory to delete"
  #mkdir $stagingDir || echo "Container exists"
  #echo "About to copy $stagingDir"
  #cp -r * $stagingDir
  #cd $stagingDir

  #mkdir $buildDir || echo "Couldn't create $buildDir. Maybe already exists"
  swift build --build-path $buildDirName
  executablePath="$buildDirName/debug/raspberry-pi"
  #echo "About to copy $executablePath"
  #cp $executablePath $originalDir
  #echo "About to copy $buildDir"
  #rm -rf $originalDir/$buildDirName 
  #cp -r $buildDir $originalDir
}


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
