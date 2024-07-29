#!/usr/bin/env bats

@test "es2_info" {
    expected_EGL_CLIENT_APIS="OpenGL_ES"
    expected_GL_VERSION="OpenGL ES"
    expected_GL_RENDERER="PowerVR A-Series AXE-1-16M"

    docker container exec -it --user torizon graphics-tests es2_info 2>&1 | tee /tmp/es2_info.log

    output=$(cat /tmp/es2_info.log)

    GL_RENDERER=$(echo "$output" | grep "GL_RENDERER" | cut -d ':' -f 2 | xargs)
    EGL_CLIENT_APIS=$(echo "$output" | grep "EGL_CLIENT_APIS" | cut -d ':' -f 2 | xargs)
    GL_VERSION=$(echo "$output" | grep -v "EGL_VERSION" | grep "GL_VERSION" | cut -d ':' -f 2 | xargs)

    if [ "$GL_RENDERER" = "$expected_GL_RENDERER" ]; then
        echo "GL_RENDERER: Actual - $GL_RENDERER vs Expected - $expected_GL_RENDERER"
    else
        echo "GL_RENDERER: Actual - $GL_RENDERER vs Expected - $expected_GL_RENDERER (Mismatch)"
    fi

    if [ "$EGL_CLIENT_APIS" = "$expected_EGL_CLIENT_APIS" ]; then
        echo "EGL_CLIENT_APIS: Actual - $EGL_CLIENT_APIS vs Expected - $expected_EGL_CLIENT_APIS"
    else
        echo "EGL_CLIENT_APIS: Actual - $EGL_CLIENT_APIS vs Expected - $expected_EGL_CLIENT_APIS (Mismatch)"
    fi

    if [ "$GL_VERSION" = "$expected_GL_VERSION" ]; then
        echo "GL_VERSION: Actual - $GL_VERSION vs Expected - $expected_GL_VERSION"
    else
        echo "GL_VERSION: Actual - $GL_VERSION vs Expected - $expected_GL_VERSION (Mismatch)"
    fi
}

@test "GLMark2" {
    SCORE_PASS_THRESHOLD=220
    
    docker container exec -it graphics-tests glmark2-es2-wayland -b shading:duration=5.0 -b build:use-vbo=false -b texture 2>&1 | tee /tmp/glmark2.log

    score=$(< /tmp/glmark2.log grep -i "score" | cut -d: -f2 | xargs)

    if [ "$score" -ge "$SCORE_PASS_THRESHOLD" ]; then
        echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD"
    else
        echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD (Mismatch)"
    fi
}
