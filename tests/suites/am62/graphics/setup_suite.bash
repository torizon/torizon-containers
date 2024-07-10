setup_suite() {

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "on" > "$dir/status"
        fi
    done

    docker container run -d -it \
            --name=graphics-tests -v /dev:/dev --device-cgroup-rule="c 4:* rmw"  \
            --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 199:* rmw" \
            --device-cgroup-rule="c 226:* rmw" \
            torizon/graphics-tests-am62:next
}

teardown_suite() {
    docker container stop graphics-tests
    docker image rm -f $(docker container inspect -f '{{.Image}}' graphics-tests)
    docker container rm graphics-tests

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
         fi
    done
}
