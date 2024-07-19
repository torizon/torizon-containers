setup_suite() {

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "on" > "$dir/status"
        fi
    done

    docker container stop weston || true
    docker container rm weston || true

    docker container run -d --name=weston --net=host \
    --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
    -v /run/udev/:/run/udev/ --device-cgroup-rule="c 4:* rmw" \
    --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 226:* rmw" \
    --device-cgroup-rule="c 10:223 rmw" torizon/weston-am62:next \
    --developer --tty=/dev/tty7 -- --debug

    sleep 10

    docker container stop graphics-tests || true
    docker container rm graphics-tests || true

    # use tail -f /dev/null to keep container running
    docker container run -d --name=graphics-tests \
        -v /dev:/dev -v /tmp:/tmp \
        --device-cgroup-rule="c 226:* rmw" \
        torizon/graphics-tests-am62:next tail -f /dev/null

    sleep 10
}

teardown_suite() {
    docker container stop weston

    if [ -z "$DO_NOT_RM_ON_TEARDOWN" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' weston)
    else
        echo "Skipping Docker image removal due to DO_NOT_RM_ON_TEARDOWN environment variable."
    fi

    docker container rm weston

    docker container stop graphics-tests

    if [ -z "$DO_NOT_RM_ON_TEARDOWN" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' graphics-tests)
    else
        echo "Skipping Docker image removal due to DO_NOT_RM_ON_TEARDOWN environment variable."
    fi

    docker container rm graphics-tests

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
        fi
    done

    rm /tmp/es2_info.log
    rm /tmp/glmark2.log
}
