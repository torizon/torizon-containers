weston_image="torizon/weston-am62:next"
weston_container="weston"

chromium_image="torizon/chromium-am62:next"
chromium_container="chromium"

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

    docker container stop ${chromium_container} || true
    docker container rm ${chromium_container} || true

    remove-docker-image-if-outdated.sh ${chromium_image}

    # FIXME: healthchecks instead of sleep
    docker container run -d --name=${chromium_container} \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/dri:/dev/dri --device-cgroup-rule='c 226:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    ${chromium_image} \
    --virtual-keyboard http://info.cern.ch/hypertext/WWW/TheProject.html

    # chromium_container can take a while to fully load
    sleep 30
}

teardown_suite() {
    docker container stop ${weston_container}

    if [ "$DO_NOT_RM_ON_TEARDOWN" = "true" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' ${weston_container})
    else
        echo "Skipping Docker image removal due to DO_NOT_RM_ON_TEARDOWN environment variable."
    fi

    docker container rm ${weston_container}

    docker container stop ${chromium_container}

    if [ "$DO_NOT_RM_ON_TEARDOWN" = "true" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' ${chromium_container})
    else
        echo "Skipping Docker image removal due to DO_NOT_RM_ON_TEARDOWN environment variable."
    fi

    docker container rm ${chromium_container}

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
        fi
    done
}
