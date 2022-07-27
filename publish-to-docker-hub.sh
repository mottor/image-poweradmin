#!/bin/bash

IMAGE_NAME="mottor1/poweradmin"
VERSION=$(cat VERSION.md | head -n 1)

docker login ## Enter login and pass

docker build --tag "$IMAGE_NAME:latest" --tag "$IMAGE_NAME:$VERSION" .

for i in "$VERSION" "latest"; do
  echo " "
  echo "-----------"
  echo "pushing '$IMAGE_NAME:$i'";
  docker push "$IMAGE_NAME:$i";
done

echo " "
echo "[ DONE ]"
echo " "
