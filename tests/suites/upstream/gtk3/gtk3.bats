#!/usr/bin/env bats

@test "Check if weston container is running" {
    docker container ls | grep -q weston
    status=$?

    if [[ "$status" -ne 0 ]]; then
        echo "Weston container is not running"
        exit 1
    else
        echo "Weston container is running"
    fi
}

@test "Check if gtk3 container is running" {
    docker container ls | grep -q gtk3-tests
    status=$?

    if [[ "$status" -ne 0 ]]; then
        echo "GTK 3 container is not running"
        exit 1
    else
        echo "GTK 3 container is running"
    fi
}

@test "Simple GTK 3 test" {
    bats_require_minimum_version 1.5.0

    RUN_SIMPLE_GTK_3_TEST='simple-gtk3-test'

    run -124 docker container exec gtk3-tests timeout 10s $RUN_SIMPLE_GTK_3_TEST

    echo $status

    echo "Ran for 10 seconds without crashing, terminated by timeout."
}

@test "GTK 3 example" {
    bats_require_minimum_version 1.5.0

    RUN_GTK_3_EXAMPLE='gtk3-icon-browser'

    run -124 docker container exec gtk3-tests timeout 10s $RUN_GTK_3_EXAMPLE

    echo $status

    echo "Ran for 10 seconds without crashing, terminated by timeout."
}
