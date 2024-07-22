#!/usr/bin/env bats

@test "Check if base container is ing" {
    status=$(docker container ls | grep -q graphics-tests)
    if [ "$status" -ne 0 ]; then
        echo "Base container is not ing"
        result=1
    else
        echo "Base container is ing"
        result=0
    fi
    [ "$result" -eq 0 ]
    
}

@test "Test kmscube" {
    if grep disconnected /sys/class/drm/*/status; then
        echo "kmscube test might fail, if display is not connected. Force the connector state to \"on\" and the test anyway."
        echo on > /sys/class/drm/*/status
    fi

    docker container exec -it graphics-tests kmscube -c 2048 -D /dev/dri/card0 | tee /tmp/kmscube.txt

    KMS_TEST=1
    FPSs=$(grep 'fps)' /tmp/kmscube.txt | cut -d '(' -f 2 | cut -d ' ' -f 1)
    for FPS in $FPSs; do
       [ 1 -eq "$(echo "$FPS >= 55" | bc)" ] && [ 1 -eq "$(echo "$FPS < 100" | bc)" ] && KMS_TEST=0 && break 2
    done
}

@test "Check OpenCL installation" {
    expected_platform_names=("PowerVR" "rusticl" "Clover")
    expected_platform_vendors=("Imagination Technologies" "Mesa/X.org" "Mesa")
    expected_device_name="PowerVR A-Series AXE-1-16M"
    expected_device_vendor="Imagination Technologies"
    expected_device_version="OpenCL 3.0 "
    expected_driver_version="23.3@6512818"

    docker container exec -it graphics-tests clinfo --json | tee /tmp/clinfo.txt
    clinfo_json=$(cat /tmp/clinfo.txt)

    for expected_platform_name in "${expected_platform_names[@]}"; do
        jq -e --arg name "$expected_platform_name" '.platforms[] | select(.CL_PLATFORM_NAME == $name)' <<< "${clinfo_json}" > /dev/null
        [ $? -eq 0 ]
    done

    for expected_platform_vendor in "${expected_platform_vendors[@]}"; do
        jq -e --arg vendor "$expected_platform_vendor" '.platforms[] | select(.CL_PLATFORM_VENDOR == $vendor)' <<< "${clinfo_json}" > /dev/null
        [ $? -eq 0 ]
    done

    jq -e --arg name "$expected_device_name" '.devices[].online[] | select(.CL_DEVICE_NAME == $name)' <<< "${clinfo_json}" > /dev/null
    [ $? -eq 0 ]
    jq -e --arg vendor "$expected_device_vendor" '.devices[].online[] | select(.CL_DEVICE_VENDOR == $vendor)' <<< "${clinfo_json}" > /dev/null
    [ $? -eq 0 ]
    jq -e --arg version "$expected_device_version" '.devices[].online[] | select(.CL_DEVICE_VERSION == $version)' <<< "${clinfo_json}" > /dev/null
    [ $? -eq 0 ]
    jq -e --arg driver_version "$expected_driver_version" '.devices[].online[] | select(.CL_DRIVER_VERSION == $driver_version)' <<< "${clinfo_json}" > /dev/null
    [ $? -eq 0 ]
}
