#!/usr/bin/env bats

@test "Check if base container is running" {
    status=$(docker container ls | grep -q qt5-wayland-examples)
    if [ "$status" -ne 0 ]; then
        echo "Base container is not running"
        result=1
    else
        echo "Base container is running"
        result=0
    fi
    [ "$result" -eq 0 ]
    
}

@test "EGL kmscube" {
    RUN_KMS_CUBE_EXAMPLE='kms-setup.sh /usr/lib/aarch64-linux-gnu/qt5/examples/opengl/cube/cube'
    docker container exec -d -e QT_QPA_PLATFORM=eglfs qt5-wayland-examples $RUN_KMS_CUBE_EXAMPLE

    # Make sure the application is running
    sleep 10

    # Check if the application process is running
    KMS_TOP=$(docker top qt5-wayland-examples)
    echo "$KMS_TOP" | grep -v "/bin/sh" | grep "qt5/examples/opengl/cube/cube"
    CONDITIONAL=$?

    # Finish EGL kms execution
    kill "$(ps -A | tr -s ' ' | grep cube | cut -d' ' -f 2)"

    sleep 5

    # On error, show the top we parsed
    if [ "$CONDITIONAL" -eq "1" ]; then
        echo "=== EGL KMS cube example test qt5-wayland-examples top ==="
        echo "$KMS_TOP"
        echo "======"
    fi

    [ "$CONDITIONAL" -eq "0" ]
}

@test "LinuxFB shapedclock" {
    RUN_LINUXFB_SHAPEDCLOCK_EXAMPLE='/usr/lib/aarch64-linux-gnu/qt5/examples/widgets/widgets/shapedclock/shapedclock'
    docker container exec -d -e QT_QPA_PLATFORM=linuxfb qt5-wayland-examples $RUN_LINUXFB_SHAPEDCLOCK_EXAMPLE

    # Make sure the application is running
    sleep 20

    # Check if the application process is running
    LINUXFB_TOP=$(docker top qt5-wayland-examples)
    echo "$LINUXFB_TOP" | grep -v "/bin/sh" | grep "qt5/examples/widgets/widgets/shapedclock/shapedclock"
    CONDITIONAL=$?

    # Finish LinuxFB execution
    kill "$(ps -A | tr -s ' ' | grep shapedclock | cut -d' ' -f 2)"

    sleep 5

    # On error, show the top we parsed
    if [ "$CONDITIONAL" -eq "1" ]; then
        echo "=== LinuxFB shapedclock example test qt5-wayland-examples top ==="
        echo "$KMS_TOP"
        echo "======"
    fi

    [ "$CONDITIONAL" -eq "0" ]
}
