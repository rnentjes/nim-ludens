#version 120

#ifdef GL_ES
precision mediump float;
#endif

varying vec3 v_color;

void main() {
    gl_FragColor = vec4(v_color, 1);
}
