graphics_tests_image="torizon/graphics-tests-am62:stable-rc"
graphics_tests_container="graphics-tests"

weston_image="torizon/weston-am62:stable-rc"
weston_container="weston"

setup_suite() {

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "on" > "$dir/status"
        fi
    done

    docker container stop ${weston_container} || true
    docker container rm ${weston_container} || true

    docker container run -d --name=${weston_container} --net=host \
    --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
    -v /run/udev/:/run/udev/ \
    --device-cgroup-rule="c 4:* rmw" --device-cgroup-rule="c 13:* rmw" \
    --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 10:223 rmw" \
    ${weston_image} --developer --tty=/dev/tty7 -- --debug

    sleep 10

    docker container stop ${graphics_tests_container} || true
    docker container rm ${graphics_tests_container} || true

    # use tail -f /dev/null to keep container running
    docker container run -d --name=${graphics_tests_container} \
        -v /dev:/dev -v /tmp:/tmp \
        --device-cgroup-rule="c 226:* rmw" \
        ${graphics_tests_image} tail -f /dev/null

    sleep 10
}

teardown_suite() {
    docker container stop ${weston_container}

    if [ "$RM_ON_TEARDOWN" = "true" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' ${weston_container})
    else
        echo "Skipping Docker image removal due to RM_ON_TEARDOWN environment variable."
    fi

    docker container rm ${weston_container}

    docker container stop ${graphics_tests_container}

    if [ "$RM_ON_TEARDOWN" = "true" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' ${graphics_tests_container})
    else
        echo "Skipping Docker image removal due to RM_ON_TEARDOWN environment variable."
    fi

    docker container rm ${graphics_tests_container}

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
        fi
    done

    rm /tmp/es2_info.log
    rm /tmp/glmark2.log
}
