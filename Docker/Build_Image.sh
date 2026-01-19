IMAGE_NAME="firefox-gui"
IMAGE_TAG="1.0"

docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -f ./Firefox/Dockerfile.firefox ./Firefox/

docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  ${IMAGE_NAME}:${IMAGE_TAG}