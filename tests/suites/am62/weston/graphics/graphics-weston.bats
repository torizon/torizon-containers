#!/usr/bin/env bats

@test "es2_info" {
    docker container exec --user torizon graphics-tests es2_info 2>&1 | tee /tmp/es2_info.log

    GL_RENDERER=$(grep "GL_RENDERER" < /tmp/es2_info.log | cut -d ':' -f 2 | tr -d '\n' | tr -d '\r' | xargs)
    EGL_CLIENT_APIS=$(grep "EGL_CLIENT_APIS" < /tmp/es2_info.log | cut -d ':' -f 2 | tr -d '\n' | tr -d '\r' | xargs)
    GL_VERSION=$(grep -w "GL_VERSION" < /tmp/es2_info.log | cut -d ':' -f 2 | tr -d '\n' | tr -d '\r' | xargs)

    [ "$GL_RENDERER" == "PowerVR A-Series AXE-1-16M" ]
    [ "$EGL_CLIENT_APIS" == "OpenGL_ES" ]
    [ "$GL_VERSION" == "OpenGL ES 3.1 build 23.3@6512818" ]
}

@test "GLMark2" {
    SCORE_PASS_THRESHOLD=220

    docker container exec graphics-tests glmark2-es2-wayland -b shading:duration=5.0 -b build:use-vbo=false -b texture 2>&1 | tee /tmp/glmark2.log

    score=$(< /tmp/glmark2.log grep -i "score" | cut -d: -f2 | xargs)

    if [ "$score" -ge "$SCORE_PASS_THRESHOLD" ]; then
        echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD"
    else
        echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD (Mismatch)"
	exit 1
    fi
}
