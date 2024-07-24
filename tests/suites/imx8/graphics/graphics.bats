#!/usr/bin/env bats

@test "Check if base container is running" {
    status=$(docker container ls | grep -q graphics-tests)
    if [ "$status" -ne 0 ]; then
        echo "Base container is not running"
        result=1
    else
        echo "Base container is running"
        result=0
    fi
    [ "$result" -eq 0 ]
    
}

@test "Test kmscube" {
    docker container exec -it graphics-tests kmscube -c 2048 -D /dev/dri/card0 | tee /tmp/kmscube.txt

    FPSs=$(grep 'fps)' /tmp/kmscube.txt | cut -d '(' -f 2 | cut -d ' ' -f 1)
    for FPS in $FPSs; do
       [ 1 -eq "$(echo "$FPS >= 55" | bc)" ] && [ 1 -eq "$(echo "$FPS < 100" | bc)" ]
    done
}

@test "Modetest" {
    docker container exec graphics-tests modetest
}
