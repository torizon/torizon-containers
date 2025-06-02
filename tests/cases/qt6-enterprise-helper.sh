#!/usr/bin/env bash

setup_qt6_enterprise() {
  QT6_ENTERPRISE_RUN_AM62=$(read-docker-run.sh "/runs/qt6-enterprise/qt6-enterprise-am62-compose.run" "qt6-enterprise-am62" "qt6-enterprise")
  QT6_ENTERPRISE_RUN_IMX8
  QT6_ENTERPRISE_RUN_IMX8=$(read-docker-run.sh "/runs/qt6-enterprise/qt6-enterprise-imx8-compose.run" "qt6-enterprise-imx8" "qt6-enterprise")
  export QT6_ENTERPRISE_RUN_IMX8
  QT6_ENTERPRISE_RUN_UPSTREAM=$(read-docker-run.sh "/runs/qt6-enterprise/qt6-enterprise-upstream-compose.run" "qt6-enterprise" "qt6-enterprise")

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
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN="$QT6_ENTERPRISE_RUN_AM62"
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    # For tests, use the demo container
    DOCKER_RUN="$QT6_ENTERPRISE_DEMO_RUN_IMX8"
  else
    DOCKER_RUN="$QT6_ENTERPRISE_RUN_UPSTREAM"
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
