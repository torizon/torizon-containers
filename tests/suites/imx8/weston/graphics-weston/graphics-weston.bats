#!/usr/bin/env bats

@test "Is Weston running?" {
    docker container ls | grep -q weston
    status=$?

    [[ "$status" -eq 0 ]]
    echo "Weston container is running"
}

# note that adding screenshot comparison tests here must be done carefully, as
# we don't necessarily close the windows for the tests below.

# using the built-in `timeout` as a pretty decent way to test non-returning commands.
@test "Weston Simple EGL" {
    run timeout 10s docker container exec weston weston-simple-egl
    # Check if the command was terminated by timeout (exit code 124) or succeeded (exit code 0)
    if [ "$status" -eq 124 ]; then
        echo "Ran for 10 seconds without crashing, terminated by timeout."
    else
        [ "$status" -eq 0 ]
    fi
}

@test "Weston Terminal" {
    run timeout 5s docker container exec weston weston-terminal
    # Check if the command was terminated by timeout (exit code 124) or succeeded (exit code 0)
    if [ "$status" -eq 124 ]; then
        echo "Ran for 5 seconds without crashing, terminated by timeout."
    else
        [ "$status" -eq 0 ]
    fi
}


@test "es2_info" {
    expected_EGL_CLIENT_APIS="OpenGL_ES"
    expected_GL_VERSION="OpenGL ES"
    expected_GL_RENDERER="PowerVR A-Series AXE-1-16M"

    docker container exec -it --user torizon graphics-tests es2_info 2>&1 | tee /tmp/es2_info.log

    output=$(cat /tmp/es2_info.log)

    GL_RENDERER=$(echo "$output" | grep "GL_RENDERER" | cut -d ':' -f 2 | xargs)
    EGL_CLIENT_APIS=$(echo "$output" | grep "EGL_CLIENT_APIS" | cut -d ':' -f 2 | xargs)
    GL_VERSION=$(echo "$output" | grep -v "EGL_VERSION" | grep "GL_VERSION" | cut -d ':' -f 2 | xargs)

    [[ "$GL_RENDERER" == "$expected_GL_RENDERER" ]]
    echo "GL_RENDERER: Actual - $GL_RENDERER vs Expected - $expected_GL_RENDERER"

    [[ "$EGL_CLIENT_APIS" == "$expected_EGL_CLIENT_APIS" ]]
    echo "EGL_CLIENT_APIS: Actual - $EGL_CLIENT_APIS vs Expected - $expected_EGL_CLIENT_APIS"

    [[ "$GL_VERSION" == "$expected_GL_VERSION" ]]
    echo "GL_VERSION: Actual - $GL_VERSION vs Expected - $expected_GL_VERSION"
}

@test "GLMark2" {
    SCORE_PASS_THRESHOLD=220
    
    docker container exec -it graphics-tests glmark2-es2-wayland -b shading:duration=5.0 -b build:use-vbo=false -b texture 2>&1 | tee /tmp/glmark2.log

    score=$(< /tmp/glmark2.log grep -i "score" | cut -d: -f2 | xargs)

    [[ "$score" -ge "$SCORE_PASS_THRESHOLD" ]]
    echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD"
}
