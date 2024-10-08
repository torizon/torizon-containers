setup_suite() {
    docker container stop qt5-wayland-examples || true
    docker container rm qt5-wayland-examples || true

    docker container run -d -it --net=host --name=qt5-wayland-examples \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule="c 4:* rmw"  --device-cgroup-rule="c 13:* rmw" \
             --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 29:* rmw" \
             torizon/qt5-wayland-examples-imx8:stable-rc

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "on" > "$dir/status"
        fi
    done
}

teardown_suite() {
    docker container stop qt5-wayland-examples
    docker image rm -f $(docker container inspect -f '{{.Image}}' qt5-wayland-examples)
    docker container rm qt5-wayland-examples

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
        fi
    done

}
