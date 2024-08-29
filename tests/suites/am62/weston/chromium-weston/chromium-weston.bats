#!/usr/bin/env bats

function take_screenshot(){
    local container_name="$1"

    docker exec "$container_name" weston-screenshooter
}

function copy_screenshot(){
    local container_name="$1"

    docker cp "${container_name}:/home/torizon/." .
    docker exec "$container_name" sh -c "rm /home/torizon/wayland-screenshot*.png"
    mv wayland-screenshot*.png /home/torizon/screenshot.png
}

image_compare() {
# Example usage:
# image_compare image1.png image2.png <threshold>
    if [ "$#" -ne 3 ]; then
        echo "Usage: image_compare image1 image2 threshold"
        exit 1
    fi

    image1="$1"
    image2="$2"
    threshold="$3"

    difference=$(compare -metric AE "$image1" "$image2" null: 2>&1)

    if [ "$difference" -gt "$threshold" ]; then
        echo "Difference below threshold: $difference"
    else
        echo "Difference above threshold: $difference"
    fi
}

@test "Is Weston running?" {
    status=$(docker container ls | grep -q weston)
    if [ "$status" -ne 0 ]; then
        echo "Container is not running"
    else
        echo "Container is running"
    fi
}

@test "Is Chromium running?" {
    status=$(docker container ls | grep -q chromium)
    if [ "$status" -ne 0 ]; then
        echo "Container is not running"
    else
        echo "Container is running"
    fi
}

@test "Chromium Screenshot Comparison" {
    take_screenshot "weston"
    copy_screenshot "weston"
    image_compare /suites/am62/weston/chromium-weston/chromium-reference-screenshot.png /home/torizon/screenshot.png 100
}

@test "Chromium webglreport test" {
    docker container run --rm --name=webglreport \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/dri:/dev/dri --device-cgroup-rule='c 226:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    torizon/chromium-tests-am62:next
}
