#!/bin/bash

GIT_BRANCH=`git branch | grep \* | cut -d ' ' -f2`
IMAGE_TAG="zephyr-os:local-${GIT_BRANCH}"

echo "Warning!!!"
echo -n "This Script will delete any dangling docker images from your system. Do you wish to continue (Y/n)? "
read user_input

if ! ([ "$user_input" == "y" ] || [ "$user_input" == "Y" ]); then
	echo "Quitting!"
	exit 1
fi

# Build image with Tag
sudo docker build --rm --no-cache -f Dockerfile . -t ${IMAGE_TAG}
EXIT_STATUS=$?
if [ ! $EXIT_STATUS -eq 0 ]; then
	echo "ERROR while building docker image. Quitting!"
fi

# Delete dangling images
DANGLING_IMAGES=`sudo docker images -f "dangling=true" -q | tr '\n' ' '`
sudo docker rmi -f ${DANGLING_IMAGES}
