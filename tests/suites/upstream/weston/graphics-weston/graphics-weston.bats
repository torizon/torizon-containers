#!/usr/bin/env bats

@test "Is Weston running?" {
    docker container ls | grep -q weston
    status=$?

    if [[ "$status" -ne 0 ]]; then
        echo "Base container is not running"
        exit 1
    else
        echo "Base container is running"
    fi
}

# note that adding screenshot comparison tests here must be done carefully, as
# we don't necessarily close the windows for the tests below.

# using the built-in `timeout` as a pretty decent way to test non-returning commands.
@test "Weston Simple EGL" {
    bats_require_minimum_version 1.5.0

    run -124 timeout 10s docker container exec weston weston-simple-egl
    echo "Ran for 10 seconds without crashing, terminated by timeout."
}

@test "Weston Terminal" {
    bats_require_minimum_version 1.5.0

    run -124 timeout 5s docker container exec weston weston-terminal
    echo "Ran for 5 seconds without crashing, terminated by timeout."
}

@test "es2_info" {
    expected_EGL_CLIENT_APIS="OpenGL_ES"
    expected_GL_VERSION="OpenGL ES"
    expected_GL_RENDERER="Vivante GC"

    run docker container exec --user torizon graphics-tests es2_info

    GL_RENDERER=$(echo "$output" | grep "GL_RENDERER" | cut -d ':' -f 2 | xargs)
    EGL_CLIENT_APIS=$(echo "$output" | grep "EGL_CLIENT_APIS" | cut -d ':' -f 2 | xargs)
    GL_VERSION=$(echo "$output" | grep -v "EGL_VERSION" | grep "GL_VERSION" | cut -d ':' -f 2 | xargs)

    [[ "$GL_RENDERER" =~ "$expected_GL_RENDERER" ]]
    echo "GL_RENDERER: Actual - $GL_RENDERER vs Expected - $expected_GL_RENDERER"

    [[ "$EGL_CLIENT_APIS" =~ "$expected_EGL_CLIENT_APIS" ]]
    echo "EGL_CLIENT_APIS: Actual - $EGL_CLIENT_APIS vs Expected - $expected_EGL_CLIENT_APIS"

    [[ "$GL_VERSION" =~ "$expected_GL_VERSION" ]]
    echo "GL_VERSION: Actual - $GL_VERSION vs Expected - $expected_GL_VERSION"
}

@test "GLMark2" {
    SCORE_PASS_THRESHOLD=220

    run docker container exec graphics-tests glmark2-es2-wayland -b shading:duration=5.0 -b build:use-vbo=false -b texture

    score=$(echo "$output" | grep -i "score" | cut -d: -f2 | xargs)

    echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD"

    [[ "$score" -ge "$SCORE_PASS_THRESHOLD" ]]
}
