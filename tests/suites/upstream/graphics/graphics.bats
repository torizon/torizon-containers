#!/usr/bin/env bats

@test "Check if base container is running" {
    docker container ls | grep -q graphics-tests
    status=$?

    if [[ "$status" -ne 0 ]]; then
        echo "Base container is not running"
        exit 1
    else
        echo "Base container is running"
    fi
}

@test "Test kmscube" {
    docker container exec -it graphics-tests kmscube -c 2048 | tee /tmp/kmscube.txt

    FPSs=$(grep 'fps)' /tmp/kmscube.txt | cut -d '(' -f 2 | cut -d ' ' -f 1)

    for FPS in $FPSs; do
       [[ 1 -eq "$(echo "$FPS >= 55" | bc)" && 1 -eq "$(echo "$FPS < 100" | bc)" ]]
    done
}

@test "Modetest" {
    docker container exec graphics-tests modetest -M imx-drm
}
