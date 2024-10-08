setup_suite() {
    echo "kmscube test might fail, if display is not connected. Force the connector state to \"on\" and run the test anyway."

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "on" > "$dir/status"
        fi
    done

    docker container stop graphics-tests || true
    docker container rm graphics-tests || true

    docker container run -e ACCEPT_FSL_EULA=1 -d -it --privileged \
    --name=graphics-tests -v /dev:/dev -v /tmp:/tmp \
    torizon/graphics-tests:stable-rc
}

teardown_suite() {
    docker container stop graphics-tests
    docker image rm -f $(docker container inspect -f '{{.Image}}' graphics-tests)
    docker container rm graphics-tests

    echo "kmscube test might fail, if display is not connected. Force the connector state to \"on\" and run the test anyway."

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
         fi
    done
}
