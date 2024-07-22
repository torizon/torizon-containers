image="torizon/qt5-wayland-examples-am62:next"
container="qt5-wayland-examples"

setup_suite() {

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "on" > "$dir/status"
        fi
    done

    docker container stop ${container} || true
    docker container rm ${container} || true

    remove-docker-image-if-outdated.sh ${image}

    docker container run -d -it --net=host --name=${container} \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule="c 4:* rmw"  --device-cgroup-rule="c 13:* rmw" \
             --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 29:* rmw" \
             ${image}
}

teardown_suite() {
    docker container stop ${container}

    if [ "$RM_ON_TEARDOWN" = "true" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' ${container})
    else
        echo "Skipping Docker image removal due to RM_ON_TEARDOWN environment variable."
    fi

    docker container rm ${container}

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
         fi
    done
}
