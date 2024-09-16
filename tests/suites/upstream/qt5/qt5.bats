#!/usr/bin/env bats

@test "Check if base container is running" {
    docker container ls | grep -q qt5-wayland-examples
    status=$?

    if [[ "$status" -ne 0 ]]; then
        echo "Base container is not running"
        exit 1
    else
        echo "Base container is running"
    fi
}

@test "EGL kmscube" {
    bats_require_minimum_version 1.5.0

    RUN_KMS_CUBE_EXAMPLE='kms-setup.sh /usr/lib/arm-linux-gnueabihf/qt5/examples/opengl/cube/cube'

    run -124 docker container exec -e QT_QPA_PLATFORM=eglfs qt5-wayland-examples timeout 20s $RUN_KMS_CUBE_EXAMPLE

    echo $status

    echo "Ran for 20 seconds without crashing, terminated by timeout."
}

@test "LinuxFB shapedclock" {
    bats_require_minimum_version 1.5.0

    RUN_LINUXFB_SHAPEDCLOCK_EXAMPLE='/usr/lib/arm-linux-gnueabihf/qt5/examples/widgets/widgets/shapedclock/shapedclock'

    run -124 docker container exec -e QT_QPA_PLATFORM=linuxfb qt5-wayland-examples timeout 20s $RUN_LINUXFB_SHAPEDCLOCK_EXAMPLE

    echo "Ran for 20 seconds without crashing, terminated by timeout."
}
