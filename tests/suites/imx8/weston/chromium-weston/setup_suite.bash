setup_suite() {
    docker container stop weston || true
    docker container rm weston || true

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "on" > "$dir/status"
        fi
    done

    docker container run -d --name=weston --net=host \
    --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
    -v /run/udev/:/run/udev/ --device-cgroup-rule="c 4:* rmw" \
    --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 226:* rmw" \
    --device-cgroup-rule="c 10:223 rmw" --device-cgroup-rule="c 199:0 rmw" \
    torizon/weston-imx8:stable-rc \
    --developer --tty=/dev/tty7 -- --debug

    sleep 10

    docker container stop chromium || true
    docker container rm chromium || true

    # FIXME: healthchecks instead of sleep
    docker container run -d --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/galcore:/dev/galcore --device-cgroup-rule='c 199:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    torizon/chromium-imx8:stable-rc \
    --virtual-keyboard http://info.cern.ch/hypertext/WWW/TheProject.html
    
    # chromium can take a while to fully load
    sleep 30
}

teardown_suite() {
    docker container stop weston
    docker image rm -f $(docker container inspect -f '{{.Image}}' weston)
#    docker container rm weston

    docker container stop chromium
    docker image rm -f $(docker container inspect -f '{{.Image}}' chromium)
#    docker container rm chromium

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
        fi
    done
}
