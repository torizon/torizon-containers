#!/usr/bin/env bash

setup_qt6_enterprise() {
  # For demo containers, we need a special setup
  QT6_ENTERPRISE_DEMO_RUN_IMX8="docker container run -d -it --net=host --name=qt6-enterprise-demo \
    --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
    --device-cgroup-rule='c 4:* rmw'  --device-cgroup-rule='c 13:* rmw' \
    --device-cgroup-rule='c 226:* rmw' --device-cgroup-rule='c 29:* rmw' --device-cgroup-rule='c 199:* rmw' \
    $REGISTRY/torizon/qt6-enterprise-demo-imx8:stable-rc bash"

  docker container kill qt6-enterprise || true
  docker container rm qt6-enterprise || true
  docker container kill qt6-enterprise-demo || true
  docker container rm qt6-enterprise-demo || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN="$QT6_ENTERPRISE_DEMO_RUN_IMX8"
  else
    DOCKER_RUN=$(read-docker-run.sh "/runs/qt6-enterprise/qt6-enterprise-upstream-compose.run" "qt6-enterprise" "qt6-enterprise")
  fi

  eval "$DOCKER_RUN"

  sleep 30
}

teardown_qt6_enterprise() {
  docker container kill qt6-enterprise || true
  docker container kill qt6-enterprise-demo || true

  for container in qt6-enterprise qt6-enterprise-demo; do
    IMAGE_ID=$(docker container inspect -f '{{.Image}}' "$container" 2>/dev/null)
    if [[ -n "$IMAGE_ID" ]]; then
      docker image rm -f "$IMAGE_ID" || true
    fi
    docker container rm "$container" || true
  done
}
